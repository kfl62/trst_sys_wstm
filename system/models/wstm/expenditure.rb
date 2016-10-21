# encoding: utf-8
module Wstm
  class Expenditure < Trst::Expenditure

    has_many   :freights,   class_name: "Wstm::FreightIn",        inverse_of: :doc_exp, dependent: :destroy
    belongs_to :unit,       class_name: "Wstm::PartnerFirm::Unit",inverse_of: :apps, index: true
    belongs_to :client,     class_name: "Wstm::PartnerPerson",    inverse_of: :apps, index: true
    belongs_to :signed_by,  class_name: "Wstm::User",             inverse_of: :apps

    alias :file_name :name; alias :unit :unit_belongs_to

    index({ unit_id: 1, id_date: 1 })
    # index({ client_id: 1, id_date: 1 }) # Just when Decl-205

    accepts_nested_attributes_for :freights,
      reject_if: ->(attrs){ attrs[:qu].to_f == 0 || attrs[:id_date].empty?}

    after_save  :handle_empty_expenditure_error

    class << self
      # @todo
      def sum_mny(*args)
        opts = args.last.is_a?(Hash) ? {exp_all: false}.merge!(args.pop) : {exp_all: false}
        y,m,d = *args; today = Date.today
        y,m,d = today.year, today.month, today.day unless ( y || m || d)
        ary = opts[:exp_all] ? [:sum_003,:sum_016,:sum_out,:sum_100] : [:sum_out,:sum_100]
        ary = opts[:exp] if opts[:exp]
        if d
          ary.each_with_object([]){|v,a| a << (daily(y,m,d).sum(v) || 0.0).round(2)}
        elsif m
          ary.each_with_object([]){|v,a| a << (monthly(y,m).sum(v) || 0.0).round(2)}
        else
          ary.each_with_object([]){|v,a| a << (yearly(y).sum(v)    || 0.0).round(2)}
        end
      end
      # @todo
      def sum_freights_exp
        all.each_with_object({}) do |app,s|
          app.freights.asc(:id_stats).each_with_object(s) do |f,s|
            key = f.id_stats
            if s[key].nil?
              s[key] = [f.freight.name,f.freight.id_stats,f.pu,f.qu,f.val,f.freight.p03,f.id_date.year < 2016 ? f.val * 0.16 : 0]
            else
              s[key][3] += f.qu
              s[key][4] += f.val
              s[key][6] += f.id_date.year < 2016 ? f.val * 0.16 : 0
            end
          end
        end
      end
      # @todo
      def check_sum
        r = all.asc(:name).each_with_object([]) do |e,a|
          sum = e.freights.sum(:val).round(2)
          a << "#{e.id_date.to_s} -  #{e.name} - Dif. #{(e.sum_100 - sum).round(2)}" if e.sum_100 != sum
        end
        r.length > 0 ? r.join("\n") : "Ok"
      end
    end # Class methods

    protected
    # @todo
    def handle_empty_expenditure_error
      delete if freights.count == 0
    end
  end # Expenditure
end #Wstm
