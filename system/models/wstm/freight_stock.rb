# encoding: utf-8
module Wstm
  class FreightStock
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

    belongs_to  :freight,  class_name: 'Wstm::Freight',           inverse_of: :stks, index: true
    belongs_to  :unit,     class_name: 'Wstm::PartnerFirm::Unit', inverse_of: :fsts, index: true
    belongs_to  :doc_stk,  class_name: 'Wstm::Stock',             inverse_of: :freights, index: true

    index({ freight_id: 1, id_stats: 1, pu: 1, id_date: 1 })
    index({ id_stats: 1, pu: 1, id_date: 1 })
    index({ freight_id: 1, doc_stk_id: 1, qu: 1})

    scope :stock_now, where(id_date: Date.new(2000,1,31))
    scope :by_unit_id, ->(unit_id) {where(unit_id: unit_id)}

    before_save   :handle_freights_unit_id
    after_update  :handle_value

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
      def pos(s)
        uid = Wstm::PartnerFirm.pos(s).id
        by_unit_id(uid)
      end
      # @todo
      def sum_stks(*args)
        opts = args.last.is_a?(Hash) ? {what: :qu}.merge!(args.pop) : {what: :qu}
        y,m,d = *args; today = Date.today
        y,m,d = today.year, today.month, today.day unless ( y || m || d)
        v = opts[:what]
        if d
          (monthly(y,m).sum(v) || 0.0).round(2)
        elsif m
          (monthly(y,m).sum(v) || 0.0).round(2)
        else
          (monthly(y,1).sum(v) || 0.0).round(2)
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
      doc_stk
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
    def handle_value
      set :val, (pu * qu).round(2)
      delete if qu.round(2) == 0.0
    end
  end # FreightStock
end # Wstm
