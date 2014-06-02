# encoding: utf-8
module Wstm
  class DeliveryNote
    include Mongoid::Document
    include Mongoid::Timestamps
    include Trst::ViewHelpers
    include Trst::DateHelpers

    field :name,        type: String
    field :id_date,     type: Date,     default: -> {Date.today}
    field :id_intern,   type: Boolean,  default: false
    field :doc_name,    type: String
    field :doc_plat,    type: String
    field :charged,     type: Boolean,  default: false

    alias :file_name :name

    has_many   :freights,     class_name: "Wstm::FreightOut",         inverse_of: :doc_dln, dependent: :destroy
    belongs_to :unit,         class_name: "Wstm::PartnerFirm::Unit",  inverse_of: :dlns, index: true
    belongs_to :doc_grn,      class_name: "Wstm::Grn",                inverse_of: :dlns
    belongs_to :doc_inv,      class_name: "Wstm::Invoice",            inverse_of: :dlns
    belongs_to :client,       class_name: "Wstm::PartnerFirm",        inverse_of: :dlns_client
    belongs_to :transp,       class_name: "Wstm::PartnerFirm",        inverse_of: :dlns_transp
    belongs_to :client_d,     class_name: "Wstm::PartnerFirm::Person",inverse_of: :dlns_client
    belongs_to :transp_d,     class_name: "Wstm::PartnerFirm::Person",inverse_of: :dlns_transp
    belongs_to :signed_by,    class_name: "Wstm::User",               inverse_of: :dlns

    index({ unit_id: 1, id_date: 1 })

    scope :by_unit_id, ->(unit_id) {where(unit_id: unit_id)}

    accepts_nested_attributes_for :freights,
      reject_if: ->(attrs){ attrs[:qu].to_f == 0 }

    class << self
      # @todo
      def pos(s)
        uid = Wstm::PartnerFirm.pos(s).id
        by_unit_id(uid)
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
        ids = Wstm::FreightOut.where(:freight_id.in => Wstm::Freight.where(p03: p03).map(&:id), :doc_dln_id.in => all.map(&:id)).map(&:doc_dln_id).uniq
        where(:id.in => ids)
      end
      # @todo
      def sum_freights_grn
        all.each_with_object({}) do |dn,s|
          dn.freights.asc(:id_stats).each_with_object(s) do |f,s|
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
      def sum_freights_inv
        all.each_with_object({}) do |dn,s|
          dn.freights.asc(:id_stats).each_with_object(s) do |f,s|
            key = "#{f.id_stats}_#{"%07.4f" % f.pu_invoice}"
            if s[key].nil?
              s[key] = [f.freight.name,f.freight.id_stats,f.qu,f.val,f.pu_invoice,f.val_invoice]
            else
              s[key][2] += f.qu
              s[key][3] += f.val
              s[key][5] += f.val_invoice
            end
          end
        end
      end
      # @todo
      def auto_search(params)
        unit_id = params[:uid]
        day     = params[:day].split('-').map(&:to_i)
        where(unit_id: unit_id,id_date: Date.new(*day))
        .or(doc_name: /#{params[:q]}/i)
        .or(:client_id.in => Wstm::PartnerFirm.only(:id).where(name: /#{params[:q]}/i).map(&:id))
        .each_with_object([]) do |d,a|
          a << {id: d.id,
                text: {
                        name:  d.name,
                        title: d.freights_list.join("\n"),
                        doc_name: d.doc_name,
                        client:   d.client.name[1]}}
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
    def client_d
      Wstm::PartnerFirm.person_by_person_id(client_d_id) rescue nil
    end
    # @todo
    def increment_name(unit_id)
      dlns = Wstm::DeliveryNote.by_unit_id(unit_id).yearly(Date.today.year)
      if dlns.count > 0
        name = dlns.asc(:name).last.name.next
      else
        unit = Wstm::PartnerFirm.unit_by_unit_id(unit_id)
        prfx = Date.today.year.to_s[-2..-1]
        name = "#{unit.firm.name[0][0..2].upcase}_#{unit.slug}_AEA3-#{prfx}00001"
      end
      name
    end
    # @todo
    def freights_list
      freights.asc(:id_stats).each_with_object([]) do |f,r|
        r << "#{f.freight.name}: #{"%.2f" % f.qu} kg ( #{"%.2f" % f.pu} )"
      end
    end
  end # DeliveryNote
end # Wstm
