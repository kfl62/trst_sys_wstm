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
    field :doc_paym,    type: String
    field :sum_003,     type: Float,    default: 0.00
    field :sum_100,     type: Float,    default: 0.00
    field :sum_out,     type: Float,    default: 0.00
    field :sum_pay,     type: Float,    default: 0.00

    alias :file_name :name

    has_many   :freights,     class_name: "Wstm::FreightIn",        inverse_of: :doc_grn, dependent: :destroy
    has_many   :dlns,         class_name: "Wstm::DeliveryNote",     inverse_of: :doc_grn
    belongs_to :supplr,       class_name: "Wstm::PartnerFirm",      inverse_of: :grns_supplr
    belongs_to :transp,       class_name: "Wstm::PartnerFirm",      inverse_of: :grns_transp
    belongs_to :supplr_d,     class_name: "Wstm::PartnerFirmPerson",inverse_of: :grns_supplr
    belongs_to :transp_d,     class_name: "Wstm::PartnerFirmPerson",inverse_of: :grns_transp
    belongs_to :unit,         class_name: "Wstm::PartnerFirmUnit",  inverse_of: :grns
    belongs_to :signed_by,    class_name: "Wstm::User",             inverse_of: :grns

    index({ unit_id: 1, id_date: 1 })

    after_save    :'handle_dlns(true)'
    after_destroy :'handle_dlns(false)'

    scope :by_unit_id, ->(unit_id) {where(unit_id: unit_id)}

    accepts_nested_attributes_for :dlns
    accepts_nested_attributes_for :freights,
      reject_if: ->(attrs){ attrs[:qu].to_i == 0 }

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
      def auto_search(params)
        unit_id = params[:uid]
        day     = params[:day].split('-').map(&:to_i)
        where(unit_id: unit_id,id_date: Date.new(*day),name: /#{params[:q]}/i).each_with_object([]) do |g,a|
          a << {id: g.id,
                text: {
                        name:  g.name,
                        title: g.freights_list.join("\n"),
                        doc_name: g.doc_name,
                        supplier: g.supplr.name[1]}}
        end
      end
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
      apps = Wstm::Grn.by_unit_id(unit_id).yearly(Date.today.year)
      if apps.count > 0
        name = apps.asc(:name).last.name.next
      else
        apps = Wstm::Grn.by_unit_id(unit_id)
        unit = Wstm::PartnerFirm.unit_by_unit_id(unit_id)
        if apps.count > 0
          prefix = apps.asc(:name).last.name.split('-').last[0].next
          name = "#{unit.firm.name[0][0..2].upcase}_#{unit.slug}_NIR-#{prefix}00001"
        else
          name = "#{unit.firm.name[0][0..2].upcase}_#{unit.slug}_NIR-000001"
        end
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
  end # Grn
end # wstm
