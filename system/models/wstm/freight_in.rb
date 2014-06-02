# encoding: utf-8
module Wstm
  class FreightIn
    include Mongoid::Document
    include Mongoid::Timestamps
    include Trst::ViewHelpers
    include Trst::DateHelpers

    field :id_date,     type: Date
    field :id_stats,    type: String
    field :id_intern,   type: Boolean,   default: false
    field :pu,          type: Float,     default: 0.00
    field :qu,          type: Float,     default: 0.00
    field :val,         type: Float,     default: 0.00

    belongs_to  :freight,  class_name: 'Wstm::Freight',           inverse_of: :ins, index: true
    belongs_to  :unit,     class_name: 'Wstm::PartnerFirm::Unit', inverse_of: :ins, index: true
    belongs_to  :doc_exp,  class_name: 'Wstm::Expenditure',       inverse_of: :freights, index: true
    belongs_to  :doc_grn,  class_name: 'Wstm::Grn',               inverse_of: :freights, index: true
    belongs_to  :doc_sor,  class_name: 'Wstm::Sorting',           inverse_of: :resl_freights  #, index: true

    index({ freight_id: 1, id_stats: 1, pu: 1, id_date: 1 })
    index({ id_stats: 1, pu: 1, id_date: 1 })

    scope :by_unit_id, ->(unit_id) {where(unit_id: unit_id)}

    before_save   :handle_freights_unit_id
    after_save    :'handle_stock(true)'
    after_destroy :'handle_stock(false)'

    class << self
      # @todo
      def keys(pu = true)
        ks = all.each_with_object([]){|f,k| k << "#{f.id_stats}"}.uniq.sort!
        ks = all.each_with_object([]){|f,k| k << "#{f.id_stats}_#{"%05.2f" % f.pu}"}.uniq.sort! if pu
        ks
      end
      # @todo
      def by_key(key)
        id_stats, pu = key.split('_')
        pu.nil? ? where(id_stats: id_stats) : where(id_stats: id_stats, pu: pu.to_f)
      end
      # @todo
      def nonin(nin = true)
        where(id_intern: !nin)
      end
      # @todo
      def sorted
        where(:doc_sor_id.ne => nil)
      end
      # @todo
      def pos(s)
        uid = Wstm::PartnerFirm.pos(s).id
        by_unit_id(uid)
      end
      # @todo
      def sum_ins(*args)
        opts = args.last.is_a?(Hash) ? {what: :qu}.merge!(args.pop) : {what: :qu}
        y,m,d = *args; today = Date.today
        y,m,d = today.year, today.month, today.day unless ( y || m || d)
        v = opts[:what]
        if d
          (daily(y,m,d).sum(v) || 0.0).round(2)
        elsif m
          (monthly(y,m).sum(v) || 0.0).round(2)
        else
          (yearly(y).sum(v)    || 0.0).round(2)
        end
      end
    end # Class methods

    # @todo
    def name
      freight.name
    end
    # @todo
    def um
      freight.um rescue 'kg'
    end
    # @todo
    def unit
      Wstm::PartnerFirm.unit_by_unit_id(unit_id) rescue doc.unit
    end
    # @todo
    def doc
      doc_exp || doc_grn || doc_sor
    end
    # @todo
    def key
      "#{id_stats}_#{"%05.2f" % pu}"
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
