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

    has_many   :freights,     class_name: "Wstm::FreightOut",       inverse_of: :doc_dln, dependent: :destroy
    belongs_to :doc_grn,      class_name: "Wstm::Grn",              inverse_of: :dlns
    belongs_to :client,       class_name: "Wstm::PartnerFirm",      inverse_of: :dlns_client
    belongs_to :transporter,  class_name: "Wstm::PartnerFirm",      inverse_of: :dlns_transp
    belongs_to :client_d,     class_name: "Wstm::PartnerFirmPerson",inverse_of: :dlns_client
    belongs_to :transp_d,     class_name: "Wstm::PartnerFirmPerson",inverse_of: :dlns_transp
    belongs_to :unit,         class_name: "Wstm::PartnerFirmUnit",  inverse_of: :dlns
    belongs_to :signed_by,    class_name: "Wstm::User",             inverse_of: :dlns

    scope :by_unit_id, ->(unit_id) {where(unit_id: unit_id)}

    class << self
      # @todo
      def pos(s)
        where(unit_id: Wstm::PartnerFirm.pos(s).id)
      end
      # @todo
      def nonin(nin = true)
        where(id_intern: !nin)
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

  end # DeliveryNote
end # Wstm
