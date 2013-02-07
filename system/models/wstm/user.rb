# encoding: utf-8
module Wstm
  class User < Trst::User

    belongs_to    :unit,   class_name: 'Wstm::PartnerFirmUnit',  inverse_of: :users
    has_many      :apps,   class_name: 'Wstm::Expenditure',      inverse_of: :signed_by
    has_many      :dlns,   class_name: 'Wstm::DeliveryNote',     inverse_of: :signed_by
    has_many      :grns,   class_name: 'Wstm::Grn',              inverse_of: :signed_by
    has_many      :csss,   class_name: 'Wstm::Cassation',        inverse_of: :signed_by
    has_many      :invs,   class_name: 'Wstm::Invoice',          inverse_of: :signed_by
    embeds_many   :logins, class_name: 'Wstm::UserLogin'
    embeds_many   :stats,  class_name: 'Wstm::UserStats'

    scope :by_unit_id, ->(unit_id) {where(unit_id: unit_id)}

    class << self
    end # Class methods

    # @todo
    def login
      logins.find_or_create_by(id_date: Date.today).push(:login,Time.now)
    end
    # @todo
    def logout
      l = logins.find_or_create_by(id_date: Date.today)
      l.push(:logout,Time.now) if l.login.length > l.logout.length
    end
    # @todo
    def unit
      Wstm::PartnerFirm.unit_by_unit_id(unit_id) rescue nil
    end
    # @todo
    def work_stats(y = nil,m = nil)
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

  class UserLogin
    include Mongoid::Document
    include Mongoid::Timestamps
    include Trst::DateHelpers

    field :id_date, type: Date,     default: -> {Date.today}
    field :login,   type: Array,    default: []
    field :logout,  type: Array,    default: []

    embedded_in   :user,  class_name: 'Wstm::User'
 end # UserLogin

  class UserStats
    include Mongoid::Document
    include Mongoid::Timestamps
    include Trst::DateHelpers

    field :id_date, type: Date,     default: -> {Date.today}
    field :wdy,     type: Float,    default: 0.0
    field :out,     type: Float,    default: 0.0
    field :avg,     type: Float,    default: 0.0
    field :day,     type: Hash,     default: {}

    embedded_in   :user,  class_name: 'Wstm::User'
  end # UserStats

end # Wstm
