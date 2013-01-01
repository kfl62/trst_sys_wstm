# encoding: utf-8
module Wstm
  class Expenditure
    include Mongoid::Document
    include Mongoid::Timestamps
    include Trst::ViewHelpers
    include Trst::DateHelpers

    field :name,        type: String
    field :id_date,     type: Date,     default: -> {Date.today}
    field :id_intern,   type: Boolean,  default: false
    field :sum_003,     type: Float,    default: 0.00
    field :sum_016,     type: Float,    default: 0.00
    field :sum_100,     type: Float,    default: 0.00
    field :sum_out,     type: Float,    default: 0.00

    alias :file_name :name

    has_many   :freights,   class_name: "Wstm::FreightIn",       inverse_of: :doc_exp, dependent: :destroy
    belongs_to :client,     class_name: "Wstm::PartnerPerson",   inverse_of: :apps
    belongs_to :unit,       class_name: "Wstm::PartnerFirmUnit", inverse_of: :apps
    belongs_to :signed_by,  class_name: "Wstm::User",            inverse_of: :apps

    index({ unit_id: 1, id_date: 1 })
    scope :by_unit_id, ->(unit_id) {where(unit_id: unit_id)}

    # @todo validate id_date (min -> Date.today.month - 1)

    accepts_nested_attributes_for :freights,
      reject_if: ->(attrs){ attrs[:qu].to_f == 0 }

    class << self
      # @todo
      def pos(s)
        where(unit_id: Wstm::PartnerFirm.pos(s).id)
      end
      # @todo
      def to_txt
        all.asc(:name).each{|app| p "#{app.name} --- #{app.id_date.to_s} #{app.updated_at.strftime("%H:%M")} --- #{("%.2f" % app.sum_out).rjust(8)}"}
      end
      # @todo
      def nonin(nin = true)
        where(id_intern: !nin)
      end
      # @todo
      def auto_search(params)
        unit_id = params[:uid]
        day     = params[:day].split('-').map(&:to_i)
        where(unit_id: unit_id,id_date: Date.new(*day),name: /#{params[:q]}/i).each_with_object([]) do |e,a|
          a << {id: e.id,
                text: {
                        name:  e.name,
                        title: e.freights_list.join("\n"),
                        time:  e.updated_at.strftime("%H:%M"),
                        val:   "%.2f" % e.sum_100,
                        out:   "%.2f" % e.sum_out}}
        end
      end
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
      def check_sum
        r = all.asc(:name).each_with_object([]) do |e,a|
          sum = e.freights.sum(:val).round(2)
          a << "#{e.id_date.to_s} -  #{e.name} - Dif. #{(e.sum_100 - sum).round(2)}" if e.sum_100 != sum
        end
        r.length > 0 ? r.join("\n") : "Ok"
      end
    end # Class methods

    # @todo
    def unit
      Wstm::PartnerFirm.unit_by_unit_id(unit_id) rescue nil
    end
    # @todo
    def increment_name(unit_id)
      apps = Wstm::Expenditure.by_unit_id(unit_id).yearly(Date.today.year)
      if apps.count > 0
        name = apps.asc(:name).last.name.next
      else
        apps = Wstm::Expenditure.by_unit_id(unit_id)
        unit = Wstm::PartnerFirm.unit_by_unit_id(unit_id)
        if apps.count > 0
          #prefix = apps.asc(:name).last.name.split('-').last[0].next
          prefix = '2'
          name = "#{unit.firm.name[0][0..2].upcase}_#{unit.slug}-#{prefix}00001"
        else
          name = "#{unit.firm.name[0][0..2].upcase}_#{unit.slug}-000001"
        end
      end
      name
    end
    # @todo
    def freights_list
      freights.asc(:id_stats).each_with_object([]) do |f,r|
        r << "#{f.freight.name}: #{"%.2f" % f.qu} kg ( #{"%.2f" % f.pu} )"
      end
    end
  end # Expenditure
end #Wstm
