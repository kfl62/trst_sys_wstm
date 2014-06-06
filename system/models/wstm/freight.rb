# encoding: utf-8
module Wstm
  class Freight < Trst::Freight

    field :code,    type: Array,        default: []
    field :p03,     type: Boolean,      default: false

    has_many    :ins,      class_name: "Wstm::FreightIn",         inverse_of: :freight
    has_many    :outs,     class_name: "Wstm::FreightOut",        inverse_of: :freight
    has_many    :stks,     class_name: "Wstm::FreightStock",      inverse_of: :freight
    # @todo remove relation to unit
    belongs_to  :unit,     class_name: 'Wstm::PartnerFirm::Unit', inverse_of: :freights, index: true

    before_save :handle_code

    class << self
      # @todo remove relation to unit
      def pos(s)
        uid = Wstm::PartnerFirm.pos(s).id
        by_unit_id(uid)
      end
      # @todo
      def options_for_exp
        asc(:name).each_with_object([]){|f,a| a << [f.id,f.name,{id_stats: f.id_stats,um: f.um,pu: f.pu,p03: f.p03.to_s}]}
      end
      # @todo
      def options_for_dln
        asc(:name).each_with_object([]){|f,a| a << [f.id,f.name,{key: "#{f.id_stats}-00.0000",id_stats: f.id_stats,um: f.um,pu: 0.0,stck: (f.stks_now.sum(:qu) || 0)}]}
      end
      # @todo
      def options_for_dln_with_pu
        asc(:name).each_with_object([]) do |f,a|
          f.stks_now.where(:qu.ne => 0).asc(:pu).each do |fs|
            a << [fs.freight.id,"#{fs.freight.name}-#{"%.4f" % fs.pu}",{key: "#{f.id_stats}-#{"%.4f" % fs.pu}",id_stats: fs.id_stats,um: fs.freight.um,pu: fs.pu,stck: fs.qu}]
          end
        end
      end
      # @todo
      def options_for_stk
        asc(:name).each_with_object([]){|f,a| a << [f.id,f.name,{id_stats: f.id_stats,um: f.um,pu: f.pu}]}
      end
      # @todo
      def stats_pos(*args)
        opts = args.last.is_a?(Hash) ? {}.merge!(args.pop) : {}
        asc(:id_stats).each_with_object([]) do |f,a|
          a << [f.id,f.name,*f.stats_sum(*args,opts)]
        end
      end
      # @todo
      def stats_pos_with_pu(*args)
        opts = args.last.is_a?(Hash) ? {}.merge!(args.pop) : {}
        y,m,d = *args; today = Date.today
        y,m,d = today.year, today.month, today.day unless ( y || m || d)
        asc(:id_stats).each_with_object([]) do |f,a|
          keys = (f.ins.monthly(y,m).keys + f.outs.monthly(y,m).keys + f.stks.monthly(y,m).where(:qu.ne => 0).keys + f.stks_now.where(:qu.ne => 0).keys).uniq.sort
          keys.each do |key|
            sum = *f.stats_sum(*args,opts.merge(key: key))
            chk = (f.stks_now.by_key(key).sum(:qu) || 0.0).round(2)
            m == today.month && y == today.year ? sum.push(chk) : sum.push(sum.last)
            a << [f.id,f.name,key,*sum] unless sum.sum == 0
          end
        end
      end
      # @todo
      def stats_all(*args)
        opts = args.last.is_a?(Hash) ? {all: true}.merge!(args.pop) : {all: true}
        retval, sum_tot, part, fname = [], [0, 0, 0, 0], [], ''
        units = Wstm::PartnerFirm.unit_ids
        keys(false).each_with_index do |ids,i|
          part[i] = []
          units.each do |u|
            if Wstm::PartnerFirm.unit_by_unit_id(u).active?(*args)
              f = find_by(unit_id: u, id_stats: ids)
              if f
                sum_pos = f.stats_sum(*args,opts)
                part[i] << sum_pos.pop
                sum_tot = sum_tot.zip(sum_pos).map{|x| x.inject(:+)}
                fname = f.name
              else
                part[i] << 0
              end
            end
          end
          retval << [fname,sum_tot,part[i],(sum_tot.last - part[i].sum).round(2)].flatten
          sum_tot, fname = [0, 0, 0, 0], ''
        end
        retval
      end
      # @todo
      def stats_one(*args)
        opts = args.last.is_a?(Hash) ? {}.merge!(args.pop) : {}
        i,y,m = *args; today = Date.today; retval, sum_tot = [], [0,0]
        f   = find(i)
        y ||= today.year; m ||= today.month
        days_in_month = (Date.new(y, 12, 31) << (12 - m)).day
        final = f.stks.sum_freights(y,m,opts)
        (1..days_in_month).each do |i|
          f_ins   = f.ins.sum_freights(y,m,i,opts)
          f_out   = f.outs.sum_freights(y,m,i,opts)
          sum_tot = sum_tot.zip([f_ins,f_out]).map{|x| x.inject(:+)}
          final   = (final + f_ins - f_out).round(2)
          retval << [Date.new(y,m,i).to_s, f_ins, f_out, final] unless (f_ins == 0 && f_out == 0)
        end
        retval << ['TOTAL',sum_tot,final].flatten
      end
    end # Class methods

    # @todo remove relation to unit
    def unit
      Wstm::PartnerFirm.unit_by_unit_id(unit_id) rescue nil
    end
    # @todo
    def stats_sum(*args)
      opts = args.last.is_a?(Hash) ? {}.merge!(args.pop) : {}
      key = opts[:key] || id_stats
      if opts[:all]
        s = stks.by_key(key).sum_freights(*args,opts)
        i = ins.by_key(key).sum_freights(*args,opts)
        o = outs.by_key(key).sum_freights(*args,opts)
        i_nin = ins.by_key(key).nonin.sum_freights(*args,opts) + ins.by_key(key).sorted.sum_freights(*args,opts)
        o_nin = outs.by_key(key).nonin.sum_freights(*args,opts) + outs.by_key(key).sorted.sum_freights(*args,opts)
        [s,i_nin,o_nin,(s + i_nin - o_nin).round(2), (s + i - o).round(2)]
      else
        s = stks.by_key(key).sum_freights(*args,opts)
        i = ins.by_key(key).sum_freights(*args,opts)
        o = outs.by_key(key).sum_freights(*args,opts)
        [s,i,o,(s + i - o).round(2)]
      end
    end
    # @todo
    def stats_one(*args)
      args = args.unshift(id)
      self.class.stats_one(*args)
    end
    # @todo
    def stks_now
      stks.where(doc_stk_id: unit.stock_now.id)
    end
    # @todo
    def stock_by_key(key)
      stks_now.by_key(key).sum(:qu) || 0
    end
    protected
    # @todo
    def handle_code
      self.code = code.split(',').flatten
    end
  end # Freight
end # Wstm
