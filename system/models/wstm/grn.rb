# encoding: utf-8
module Wstm
  class Grn
    include Mongoid::Document
    include Mongoid::Timestamps
    include Trst::ViewHelpers
    include Trst::DateHelpers

    field :name,        type: String
    field :id_date,     type: Date,     default: -> {Date.today}
    field :id_intern,   type: Boolean,  default: false
    field :doc_type,    type: String
    field :doc_name,    type: String
    field :doc_date,    type: Date
    field :doc_plat,    type: String
    field :sum_003,     type: Float,    default: 0.00
    field :sum_100,     type: Float,    default: 0.00
    field :sum_out,     type: Float,    default: 0.00
    field :charged,     type: Boolean,  default: false

    alias :file_name :name

    has_many   :freights,     class_name: "Wstm::FreightIn",        inverse_of: :doc_grn, dependent: :destroy
    has_many   :dlns,         class_name: "Wstm::DeliveryNote",     inverse_of: :doc_grn
    belongs_to :supplr,       class_name: "Wstm::PartnerFirm",      inverse_of: :grns_supplr
    belongs_to :transp,       class_name: "Wstm::PartnerFirm",      inverse_of: :grns_transp
    belongs_to :supplr_d,     class_name: "Wstm::PartnerFirmPerson",inverse_of: :grns_supplr
    belongs_to :transp_d,     class_name: "Wstm::PartnerFirmPerson",inverse_of: :grns_transp
    belongs_to :doc_inv,      class_name: "Wstm::Invoice",          inverse_of: :grns
    belongs_to :unit,         class_name: "Wstm::PartnerFirmUnit",  inverse_of: :grns
    belongs_to :signed_by,    class_name: "Wstm::User",             inverse_of: :grns

    index({ unit_id: 1, id_date: 1 })

    after_save    :'handle_dlns(true)'
    after_save    :'handle_invs(true)'
    after_destroy :'handle_dlns(false)'
    after_destroy :'handle_invs(false)'

    scope :by_unit_id, ->(unit_id) {where(unit_id: unit_id)}

    accepts_nested_attributes_for :dlns
    accepts_nested_attributes_for :freights,
      reject_if: ->(attrs){ attrs[:qu].to_f == 0 }

    class << self
      # @todo
      def pos(s)
        where(unit_id: Wstm::PartnerFirm.pos(s).id)
      end
      # @todo
      def nonin(nin = true)
        where(id_intern: !nin)
      end
      # @todo
      def charged(b = true)
        where(charged: b)
      end
      # @todo
      def by_p03(p03 = true)
        ids = Wstm::FreightIn.where(:freight_id.in => Wstm::Freight.where(p03: p03).map(&:id), :doc_grn_id.in => all.map(&:id)).map(&:doc_grn_id).uniq
        where(:id.in => ids)
      end
      # @todo
      def auto_search(params)
        unit_id = params[:uid]
        day     = params[:day].split('-').map(&:to_i)
        where(unit_id: unit_id,id_date: Date.new(*day))
        .or(doc_name: /#{params[:q]}/i)
        .or(:supplr_id.in => Wstm::PartnerFirm.only(:id).where(name: /#{params[:q]}/i).map(&:id))
        .each_with_object([]) do |g,a|
          a << {id: g.id,
                text: {
                        name:  g.name,
                        title: g.freights_list.join("\n"),
                        doc_name: g.doc_name,
                        supplier: g.supplr.name[1]}}
        end
      end
      # @todo
      def sum_freights_grn
        all.each_with_object({}) do |grn,s|
          grn.freights.asc(:id_stats).each_with_object(s) do |f,s|
            if s[f.key].nil?
              s[f.key] = [f.freight.name,f.freight.id_stats,f.pu,f.qu,(f.pu * f.qu).round(2)]
            else
              s[f.key][3] += f.qu
              s[f.key][4] += (f.pu * f.qu).round(2)
            end
          end
        end
      end
      # @todo
    end # Class methods

    # @todo
    def unit
      Wstm::PartnerFirm.unit_by_unit_id(unit_id) rescue nil
    end
    # @todo
    def transp_d
      Wstm::PartnerFirm.person_by_person_id(transp_d_id) rescue nil
    end
    # @todo
    def supplr_d
      Wstm::PartnerFirm.person_by_person_id(supplr_d_id) rescue nil
    end
    # @todo
    def increment_name(unit_id)
      grns = Wstm::Grn.by_unit_id(unit_id).yearly(Date.today.year)
      if grns.count > 0
        name = grns.asc(:name).last.name.next
      else
        unit = Wstm::PartnerFirm.unit_by_unit_id(unit_id)
        prfx = Date.today.year.to_s[-2..-1]
        name = "#{unit.firm.name[0][0..2].upcase}_#{unit.slug}_NIR-#{prfx}00001"
      end
      name
    end
    # @todo
    def freights_list
      freights.asc(:id_stats).each_with_object([]) do |f,r|
        r << "#{f.freight.name}: #{"%.2f" % f.qu} kg ( #{"%.2f" % f.pu} )"
      end
    end
    protected
    # @todo
    def handle_dlns(add_remove)
      dlns.each{|dln| dln.set(:charged,add_remove)}
      dlns.each{|dln| dln.set(:doc_grn_id,nil)} if add_remove == false
    end
    # @todo
    def handle_invs(add_remove)
      if add_remove
        inv = Wstm::Invoice.create(
          name:         doc_name,
          id_date:      doc_date,
          id_intern:    true,
          doc_name:     doc_name,
          sum_100:      sum_100,
          deadl:        self[:deadl] || Date.today + 30.days,
          payed:        false,
          client_id:    supplr_id,
          client_d_id:  supplr_d_id || (supplr.people.first.id rescue nil),
          signed_by_id: signed_by.id
        )
        unset(:deadl)
        freights.each do |f|
          inv.freights.create(
            name:     f.freight.name,
            um:       f.freight.um,
            id_stats: f.id_stats,
            qu:       f.qu,
            pu:       f.pu
          )
        end
        if self[:pyms]
          inv.pyms.create(self[:pyms]) if self[:pyms][:val] != 0.0
        end
        unset(:pyms)
        set(:charged,true)
        set(:doc_inv_id,inv.id)
      else
        doc_inv.delete
      end if doc_type == 'INV'
    end
  end # Grn
end # wstm
