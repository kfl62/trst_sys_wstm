# encoding: utf-8
module Wstm
  class Invoice < Trst::Invoice

    embeds_many :freights,    class_name: "Wstm::InvoiceFreight",       inverse_of: :doc_inv, cascade_callbacks: true
    has_many    :dlns,        class_name: "Wstm::DeliveryNote",         inverse_of: :doc_inv
    has_many    :grns,        class_name: "Wstm::Grn",                  inverse_of: :doc_inv
    has_many    :pyms,        class_name: "Wstm::Payment",              inverse_of: :doc_inv, dependent: :delete
    belongs_to  :client,      class_name: "Wstm::PartnerFirm",          inverse_of: :invs_client
    belongs_to  :client_d,    class_name: "Wstm::PartnerFirm::Person",  inverse_of: :invs_client
    belongs_to  :signed_by,   class_name: "Wstm::User",                 inverse_of: :invs

    alias :file_name :name

    after_save    :'handle_dlns(true)'
    after_destroy :'handle_dlns(false)'

    accepts_nested_attributes_for :dlns, :grns
    accepts_nested_attributes_for :freights,
      reject_if: ->(attrs){ attrs[:qu].to_f == 0 }
    accepts_nested_attributes_for :pyms,
      reject_if: ->(attrs){ attrs[:val].empty? }

    class << self
    end # Class methods

    # @todo
    def client_d
      Wstm::PartnerFirm.person_by_person_id(client_d_id) rescue nil
    end
    # @todo
    def pyms_list
      pyms.asc(:id_date).each_with_object([]) do |p,r|
        r << "#{p.id_date.to_s}: #{p.text}, #{"%.2f" % p.val}"
      end.unshift("Termen: #{deadl.to_s}")
    end
    protected
    # @todo
    def handle_dlns(add_delete)
      dlns.each{|dln| dln.set(:charged,add_delete)}
      grns.each{|grn| grn.set(:charged,add_delete)}
      freights.each do |f|
        dlns.each do |dn|
          dn.freights.each do |dnf|
            if add_delete
              dnf.set(:pu_invoice,f.pu) if (dnf.id_stats == f.id_stats && dnf.pu_invoice == 0.0)
            else
              dnf.set(:pu_invoice, 0.0)
            end
            dnf.set(:val_invoice,(dnf.qu * dnf.pu_invoice).round(2))
          end
        end
      end
    end
  end # Invoice

  class InvoiceFreight < Trst::Freight
    field :qu,                type: Float,                              default: 0.00
    field :val,               type: Float,                              default: 0.00
    # temproray solutioin, @todo  convert to Hash
    field :pu,                type: Float,                              default: 0.0

    embedded_in :doc_inv,     class_name: "Wstm::Invoice",              inverse_of: :freights
  end # InvoiceFreight
end # Wstm

