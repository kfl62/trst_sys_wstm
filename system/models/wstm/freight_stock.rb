# encoding: utf-8
module Wstm
  class FreightStock < Trst::FreightStock

    belongs_to  :freight,     class_name: 'Wstm::Freight',              inverse_of: :stks, index: true
    belongs_to  :unit,        class_name: 'Wstm::PartnerFirm::Unit',    inverse_of: :fsts, index: true
    belongs_to  :doc_stk,     class_name: 'Wstm::Stock',                inverse_of: :freights, index: true

    alias :unit :unit_belongs_to; alias :name :freight_name; alias :um :freight_um

    index({ freight_id: 1, id_stats: 1, pu: 1, id_date: 1 })
    index({ id_stats: 1, pu: 1, id_date: 1 })
    index({ freight_id: 1, doc_stk_id: 1, qu: 1})

    before_save   :handle_freights_unit_id
    after_update  :handle_value

    class << self
    end # Class methods

    # @todo
    def doc
      doc_stk
    end
    protected
    # @todo
    def handle_freights_unit_id
      set(unit_id: self.doc.unit_id)
    end
    # @todo
    def handle_value
      set :val, (pu * qu).round(2)
      delete if qu.round(2) == 0.0
    end
  end # FreightStock
end # Wstm
