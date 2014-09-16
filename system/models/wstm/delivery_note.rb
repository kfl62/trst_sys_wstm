# encoding: utf-8
module Wstm
  class DeliveryNote < Trst::DeliveryNote

    has_many   :freights,     class_name: "Wstm::FreightOut",           inverse_of: :doc_dln, dependent: :destroy
    belongs_to :doc_grn,      class_name: "Wstm::Grn",                  inverse_of: :dlns
    belongs_to :doc_inv,      class_name: "Wstm::Invoice",              inverse_of: :dlns
    belongs_to :client,       class_name: "Wstm::PartnerFirm",          inverse_of: :dlns_client
    belongs_to :client_d,     class_name: "Wstm::PartnerFirm::Person",  inverse_of: :dlns_client
    belongs_to :transp,       class_name: "Wstm::PartnerFirm",          inverse_of: :dlns_transp
    belongs_to :transp_d,     class_name: "Wstm::PartnerFirm::Person",  inverse_of: :dlns_transp
    belongs_to :unit,         class_name: "Wstm::PartnerFirm::Unit",    inverse_of: :dlns
    belongs_to :signed_by,    class_name: "Wstm::User",                 inverse_of: :dlns

    alias :file_name :name; alias :unit :unit_belongs_to

    index({ unit_id: 1, id_date: 1 })

    accepts_nested_attributes_for :freights,
      reject_if: ->(attrs){ attrs[:qu].to_f == 0 }

    class << self
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
    end # Class methods

    # @todo
    def client_d
      Trst::PartnerFirm.person_by_person_id(client_d_id) rescue nil
    end
    # @todo
    def transp_d
      Trst::PartnerFirm.person_by_person_id(transp_d_id) rescue nil
    end
  end # DeliveryNote
end # Wstm
