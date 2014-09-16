# encoding: utf-8
module Wstm
  class FreightIn < Trst::FreightIn

    belongs_to  :freight,     class_name: 'Wstm::Freight',              inverse_of: :ins, index: true
    belongs_to  :unit,        class_name: 'Wstm::PartnerFirm::Unit',    inverse_of: :ins, index: true
    belongs_to  :doc_exp,     class_name: 'Wstm::Expenditure',          inverse_of: :freights, index: true
    belongs_to  :doc_grn,     class_name: 'Wstm::Grn',                  inverse_of: :freights, index: true
    belongs_to  :doc_sor,     class_name: 'Wstm::Sorting',              inverse_of: :resl_freights  #, index: true

    alias :unit :unit_belongs_to; alias :name :freight_name; alias :um :freight_um

    index({ freight_id: 1, id_stats: 1, pu: 1, id_date: 1 })
    index({ id_stats: 1, pu: 1, id_date: 1 })

    scope :sorted, -> {where(:doc_sor_id.ne => nil)}

    before_save   :handle_freights_unit_id
    after_save    :'handle_stock(true)'
    after_destroy :'handle_stock(false)'

    class << self
    end # Class methods

    # @todo
    def doc
      doc_exp || doc_grn || doc_sor
    end
    protected
    # @todo
    def handle_freights_unit_id
      set(:unit_id,self.doc.unit_id)
    end
    # @todo
    def handle_stock(add_delete)
      today = Date.today; retro = id_date.month == today.month
      stock_to_handle = retro ? [unit.stock_now] : [unit.stock_monthly(id_date.year,id_date.month), unit.stock_now]
      stock_to_handle.each do |stck|
        f = stck.freights.find_or_create_by(id_stats: id_stats, pu: pu)
        add_delete ? f.qu += qu : f.qu -= qu
        f.freight_id= freight_id
        f.id_date   = stck.id_date
        f.val       = (f.pu * f. qu).round(2)
        f.save
      end
    end
  end # FreightIn
end # Wstm
