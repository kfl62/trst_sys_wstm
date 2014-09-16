# encoding: utf-8
module Wstm
  class User < Trst::User

    belongs_to    :unit,   class_name: 'Wstm::PartnerFirm::Unit',inverse_of: :users
    has_many      :apps,   class_name: 'Wstm::Expenditure',      inverse_of: :signed_by
    has_many      :dlns,   class_name: 'Wstm::DeliveryNote',     inverse_of: :signed_by
    has_many      :grns,   class_name: 'Wstm::Grn',              inverse_of: :signed_by
    has_many      :csss,   class_name: 'Wstm::Cassation',        inverse_of: :signed_by
    has_many      :srts,   class_name: 'Wstm::Sorting',          inverse_of: :signed_by
    has_many      :invs,   class_name: 'Wstm::Invoice',          inverse_of: :signed_by
    embeds_many   :logins, class_name: 'Wstm::UserLogin'
    embeds_many   :stats,  class_name: 'Wstm::UserStats'

    scope :by_unit_id, ->(unit_id) {where(unit_id: unit_id)}

    class << self
    end # Class methods

    # @todo
    def login(ip = '')
      l = logins.find_or_create_by(id_date: Date.today)
      l.push(:login,Time.now)
      l.set(:ip,ip)
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
      wdy,out = 0.0,0.0
      if has_unit?
        s = stats.find_by(id_date: Date.new(y,m,1))
        if s && Time.parse(s.id_date.to_s) < s.updated_at.beginning_of_month && Time.parse(s.id_date.to_s) < Time.now.beginning_of_month
          return s
        else
          s = stats.find_or_create_by(id_date: Date.new(y,m,1))
          (1..Time.days_in_month(m,y)).each do |d|
            day = Date.new(y,m,d)
            exp = apps.daily(y,m,d)
            sum = exp.sum(:sum_out)
            if exp.count > 0
              hc = (6..18).step(2).each_with_object([]) do |h,a|
                a << exp.where(created_at: Time.new(y,m,d,h)..Time.new(y,m,d,h+2)).count
              end
              s.day[day.to_s] = [(logins.find_by(id_date: Date.new(y,m,d)).login.first.localtime.strftime("%H:%M:%S") rescue "00:ERROR"), exp.count, sum.round(2), *hc]
              wdy += 1
              out += sum
            end
          end
          s.wdy = wdy; s.out = out.round(2); s.avg = (out / wdy).nan? ? 0.0 : (out / wdy).round(2)
          s.save; s.touch
        end
        return s
      else
        return nil
      end
    end
  end # User

  class UserLogin
    include Mongoid::Document
    include Mongoid::Timestamps
    include Trst::DateHelpers

    field :id_date, type: Date,     default: -> {Date.today}
    field :ip,      type: String,   default: ''
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
