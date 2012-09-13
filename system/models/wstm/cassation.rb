# encoding: utf-8
module Wstm
  class Cassation
    include Mongoid::Document
    include Mongoid::Timestamps
    include Trst::ViewHelpers
    include Trst::DateHelpers

    field :name,        type: String
    field :id_date,     type: Date,     default: -> {Date.today}
    field :id_intern,   type: Boolean,  default: false
    field :text,        type: String
    field :val,         type: Float,    default: 0.00

    alias :file_name :name

    has_many   :freights,   class_name: "Wstm::FreightOut",      inverse_of: :doc_cas, dependent: :destroy
    belongs_to :unit,       class_name: "Wstm::PartnerFirmUnit", inverse_of: :csss
    belongs_to :signed_by,  class_name: "Wstm::User",            inverse_of: :csss

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

  end # Cassation
end # Wstm
