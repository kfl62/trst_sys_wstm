# encoding: utf-8
module Wstm
  class Stock
    include Mongoid::Document
    include Mongoid::Timestamps
    include Trst::ViewHelpers
    include Trst::DateHelpers

    field :name,        type: String
    field :id_date,     type: Date
    field :expl,        type: String,   default: 'Stock initial'

    has_many   :freights,   class_name: "Wstm::FreightStock",     :inverse_of => :doc_stk, dependent: :destroy
    belongs_to :unit,       class_name: "Wstm::PartnerFirm::Unit",:inverse_of => :stks, index: true

    scope :by_unit_id, ->(unit_id) {where(unit_id: unit_id)}

    accepts_nested_attributes_for :freights,
      reject_if: ->(attrs){ attrs[:qu].to_f == 0 && attrs[:pu].to_f == 0 },
      allow_destroy: true

    class << self
      # @todo
      def pos(s)
        uid = Clns::PartnerFirm.pos(s).id
        by_unit_id(uid)
      end
    end # Class methods

    # @todo
    def keys(pu = true)
      ks = freights.each_with_object([]){|f,k| k << "#{f.id_stats}"}.uniq.sort!
      ks = freights.each_with_object([]){|f,k| k << "#{f.id_stats}_#{"%05.2f" % f.pu}"}.uniq.sort! if pu
      ks
    end
    # @todo
    def unit
      Wstm::PartnerFirm.unit_by_unit_id(unit_id) rescue nil
    end
  end # Stock
end #Wstm
