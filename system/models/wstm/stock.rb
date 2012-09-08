# encoding: utf-8
module Wstm
  class Stock
    include Mongoid::Document
    include Mongoid::Timestamps
    include Trst::ViewHelpers
    include Trst::DateHelpers

    field :name,        type: String
    field :id_date,     type: Date
    field :id_intern,   type: Boolean,  default: false
    field :expl,        type: String,   default: 'Stock initial'

    has_many   :freights,   class_name: "Wstm::FreightStock",   :inverse_of => :doc
    belongs_to :unit,       class_name: "Wstm::PartnerFirmUnit",:inverse_of => :stocks

    class << self
      # @todo
      def pos(s)
        where(unit_id: Wstm::PartnerFirm.pos(s).id)
      end
    end # Class methods

    # @todo
    def unit
      Wstm::PartnerFirm.unit_by_unit_id(unit_id) rescue nil
    end

   end # Stock
end #Wstm
