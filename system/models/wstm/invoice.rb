# encoding: utf-8
module Wstm
  class Invoice
    include Mongoid::Document
    include Mongoid::Timestamps
    include Trst::ViewHelpers
    include Trst::DateHelpers

    field :name,        type: String
    field :id_date,     type: Date,     default: -> {Date.today}
    field :id_intern,   type: Boolean,  default: false
    field :doc_name,    type: String

    embeds_many :freights,     class_name: "Wstm::InvoiceFreight",   inverse_of: :doc_inv
    has_many    :dlns,         class_name: "Wstm::DeliveryNote",     inverse_of: :doc_grn
    belongs_to  :client,       class_name: "Wstm::PartnerFirm",      inverse_of: :invs_client
    belongs_to  :client_d,     class_name: "Wstm::PartnerFirmPerson",inverse_of: :invs_client

    class << self
      # @todo
      def nonin(nin = true)
        where(id_intern: !nin)
      end
    end # Class methods

    # @todo
    def client_d
      Wstm::PartnerFirm.person_by_person_id(client_d_id) rescue nil
    end

  end # Invoice

  class InvoiceFreight < Trst::Freight
    field :qu,          type: Float,     default: 0.00

    embedded_in :doc_inv,     class_name: "Wstm::Invoice",           inverse_of: :freights
  end # InvoiceFreight
end # Wstm

