# encoding: utf-8
module Wstm
  class Grn < Trst::Grn

    field :sum_003,     type: Float,    default: 0.00

    has_many   :freights,     class_name: "Wstm::FreightIn",          inverse_of: :doc_grn, dependent: :destroy
    has_many   :dlns,         class_name: "Wstm::DeliveryNote",       inverse_of: :doc_grn
    belongs_to :supplr,       class_name: "Wstm::PartnerFirm",        inverse_of: :grns_supplr
    belongs_to :supplr_d,     class_name: "Wstm::PartnerFirm::Person",inverse_of: :grns_supplr
    belongs_to :transp,       class_name: "Wstm::PartnerFirm",        inverse_of: :grns_transp
    belongs_to :transp_d,     class_name: "Wstm::PartnerFirm::Person",inverse_of: :grns_transp
    belongs_to :doc_inv,      class_name: "Wstm::Invoice",            inverse_of: :grns
    belongs_to :unit,         class_name: "Wstm::PartnerFirm::Unit",  inverse_of: :grns
    belongs_to :signed_by,    class_name: "Wstm::User",               inverse_of: :grns

    alias :file_name :name; alias :unit :unit_belongs_to

    index({ unit_id: 1, id_date: 1 })

    accepts_nested_attributes_for :dlns
    accepts_nested_attributes_for :freights,
      reject_if: ->(attrs){ attrs[:qu].to_f == 0 }

    after_save    :'handle_dlns(true)'
    after_save    :'handle_invs(true)'
    after_destroy :'handle_dlns(false)'
    after_destroy :'handle_invs(false)'

    class << self
      # @todo
      def by_p03(p03 = true)
        ids = Wstm::FreightIn.where(:freight_id.in => Wstm::Freight.where(p03: p03).map(&:id), :doc_grn_id.in => all.map(&:id)).map(&:doc_grn_id).uniq
        where(:id.in => ids)
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
    def transp_d
      Wstm::PartnerFirm.person_by_person_id(transp_d_id) rescue nil
    end
    # @todo
    def supplr_d
      Wstm::PartnerFirm.person_by_person_id(supplr_d_id) rescue nil
    end
    protected
    # @todo
    def handle_dlns(add_remove)
      dlns.each{|dln| dln.set(charged: add_remove)}
      dlns.each{|dln| dln.set(doc_grn_id: nil)} if add_remove == false
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
        set(charged: true, doc_inv_id: inv.id)
      else
        doc_inv.delete
      end if doc_type == 'INV'
    end
  end # Grn
end # wstm
