# encoding: utf-8
module Wstm
  class Cache < Trst::Cache

    field :name,        type: String,     default: -> {"DP_NR-#{Date.today.to_s}"}
    field :expl,        type: String,     default: 'Vasy Ildiko'
    field :id_intern,   type: Boolean,    default: false

    belongs_to  :unit,     class_name: 'Wstm::PartnerFirmUnit', inverse_of: :dps

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
  end # Cache
end # Wstm
