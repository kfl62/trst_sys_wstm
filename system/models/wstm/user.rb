# encoding: utf-8
module Wstm
  class User < Trst::User

    belongs_to :unit,   class_name: 'Wstm::PartnerFirmUnit',  inverse_of: :users
    has_many   :apps,   class_name: 'Wstm::Expenditure',      inverse_of: :signed_by
    has_many   :dlns,   class_name: 'Wstm::DeliveryNote',     inverse_of: :signed_by
    has_many   :grns,   class_name: 'Wstm::Grn',              inverse_of: :signed_by
    has_many   :csss,   class_name: 'Wstm::Cassation',        inverse_of: :signed_by
    has_many   :invs,   class_name: 'Wstm::Invoice',          inverse_of: :signed_by

    scope :by_unit_id, ->(unit_id) {where(unit_id: unit_id)}

    class << self
    end # Class methods

    # @todo
    def unit
      Wstm::PartnerFirm.unit_by_unit_id(unit_id) rescue nil
    end
    # @todo
    def work_stats(y = nil,m = nil,daily = false)
      y ||= Date.today.year
      m ||= Date.today.month
      a, h = [], {}
      if has_unit?
        (1..Time.days_in_month(m,y)).each do |d|
          day = Date.new(y,m,d)
          exp = apps.daily(y,m,d)
          sum = exp.sum(:sum_out)
          a << sum if exp.count > 0
          if daily
            h[day.to_s] = [exp.count, sum.round(2)] if exp.count > 0
          end
        end
        h['TOTAL'] = h.values.transpose.map{|x| x.reduce(:+)} unless h.empty?
      end
      retval = [a.length, a.sum.round(2), (a.sum / a.length rescue 0).round(2)]
      retval << h if daily
      retval
    end
  end # User
end # Wstm
