# encoding: utf-8
module Wstm
  class FreightOut
    include Mongoid::Document
    include Mongoid::Timestamps
    include Trst::ViewHelpers
    include Trst::DateHelpers

    field :id_date,     type: Date
    field :id_stats,    type: String
    field :id_intern,   type: Boolean,   default: false
    field :um,          type: String,    default: "kg"
    field :pu,          type: Float,     default: 0.00
    field :qu,          type: Float,     default: 0.00
    field :val,         type: Float,     default: 0.00
    field :pu_invoice,  type: Float,     default: 0.00
    field :val_invoice, type: Float,     default: 0.00

    belongs_to  :freight,  class_name: 'Wstm::Freight',     inverse_of: :outs
    belongs_to  :doc_dln,  class_name: 'Wstm::DeliveryNote',inverse_of: :freights
    belongs_to  :doc_cas,  class_name: 'Wstm::Cassation',   inverse_of: :freights

    index({ freight_id: 1, id_date: 1 })
    index({ doc_dln_id: 1})
    index({ doc_cas_id: 1})

    after_save    :'handle_stock(false)'
    after_destroy :'handle_stock(true)'

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
        where(id_stats: id_stats)
        where(id_stats: id_stats, pu: pu.to_f) if pu
      end
      # @todo
      def nonin(nin = true)
        where(id_intern: !nin)
      end
      # @todo
      def pos(s)
        where(:freight_id.in => Wstm::PartnerFirm.pos(s).freights.ids)
      end
      # @todo
      def sum_outs(*args)
        opts = args.last.is_a?(Hash) ? {what: :qu}.merge!(args.pop) : {what: :qu}
        y,m,d = *args; today = Date.today
        y,m,d = today.year, today.month, today.day unless ( y || m || d)
        v = opts[:what]
        if d
          daily(y,m,d).sum(v) || 0.0
        elsif m
          monthly(y,m).sum(v) || 0.0
        else
          yearly(y).sum(v)    || 0.0
        end
      end
    end # Class methods

    # @todo
    def unit
      Wstm::PartnerFirm.unit_by_unit_id(doc.unit_id)
    end
    # @todo
    def doc
      doc_dln || doc_cas
    end
    # @todo
    def key
      "#{id_stats}_#{"%05.2f" % pu}"
    end

    protected
    # @todo
    def handle_stock(add_delete)
      today = Date.today; retro = id_date.month == today.month
      stock_to_handle = retro ? [unit.stock_now] : [unit.stock_monthly(id_date.year,id_date.month), unit.stock_now]
      if add_delete
        stock_to_handle.each do |stck|
          f = stck.freights.find_or_create_by(id_stats: id_stats, pu: pu)
          f.freight_id = freight_id
          f.qu += qu
          f.val = (f.pu * f. qu).round(2)
          f.save
        end
      else
        stock_to_handle.each_with_index do |stck,i|
          out = qu
          lpu = freight.ins.last.pu == 0 ? freight.pu : freight.ins.last.pu
          fs  = stck.freights.where(id_stats: id_stats)
          if fs.count == 1
            f     = fs.first
            f.qu -= out
            f.val = (f.pu * f.qu).round(2)
            f.save
            pu = f.pu
            val= (pu * qu).round(2)
          else
            fspus = fs.where(:qu.ne => 0).asc(:pu).map(&:pu)
            fspus.delete(lpu).nil? ? fspus : fspus.push(lpu)
            fspus.delete(0).nil?   ? fspus : fspus.push(0)  if unit.main?
            fspus.each do |fspu|
              f = fs.find_by(pu: fspu)
              if out > f.qu
                if i == 0
                  self.class.new(
                    id_date:    id_date,
                    id_stats:   f.id_stats,
                    id_intern:  id_intern,
                    um:         f.um,
                    pu:         f.pu,
                    qu:         f.qu,
                    val:        (f.pu * f.qu).round(2),
                    freight_id: f.freight.id,
                    doc_dln_id: (doc_dln_id if doc_dln_id),
                    doc_cas_id: (doc_cas_id if doc_cas_id)
                  ).upsert
                end # if stock_to_handle.first
                out -= f.qu unless out == 0
                f.qu = 0
                f.val= 0
                f.save
              else
                if i == 0
                  self.class.new(
                    id_date:    id_date,
                    id_stats:   f.id_stats,
                    id_intern:  id_intern,
                    um:         f.um,
                    pu:         f.pu,
                    qu:         out,
                    val:        (f.pu * out).round(2),
                    freight_id: f.freight.id,
                    doc_dln_id: (doc_dln_id if doc_dln_id),
                    doc_cas_id: (doc_cas_id if doc_cas_id)
                  ).upsert unless out == 0
                end # if stock_to_handle.first
                f.qu -= out
                f.val = (f.pu * f.qu).round(2)
                f.save
              end # if out > f.qu
            end # each fspu
            self.delete if i == stock_to_handle.length - 1
          end # if fs.count == 1
        end # each stck
      end # if add_delete
    end

  end # FreightOut
end # Wstm
