# encoding: utf-8
module Wstm
  class Freight < Trst::Freight

    field :code,    type: String
    field :p03,     type: Boolean,      default: false

    belongs_to  :unit,     class_name: 'Wstm::PartnerFirmUnit', inverse_of: :freights
    has_many    :ins,      class_name: "Wstm::FreightIn",       inverse_of: :freight
    has_many    :outs,     class_name: "Wstm::FreightOut",      inverse_of: :freight

    class << self
      # @todo
      def pos(s)
        s = s.upcase
        where(unit_id: Wstm::PartnerFirm.pos(s).id)
      end
    end # Class methods

    #todo
    def unit
      Wstm::PartnerFirm.unit_by_unit_id(unit_id) rescue nil
    end
  end # Freight
end # Wstm
