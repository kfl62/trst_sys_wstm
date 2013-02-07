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
      wdy,out = 0.0,0.0
      if has_unit?
        s = stats.find_by(id_date: Date.new(y,m,1))
        if s && m != Date.today.month && s.created_at > Date.new(s.id_date.year,s.id_date.month,Time.days_in_month(s.id_date.month,s.id_date.year))
          return s
        else
          s = stats.find_or_create_by(id_date: Date.new(y,m,1))
          (1..Time.days_in_month(m,y)).each do |d|
            day = Date.new(y,m,d)
            exp = apps.daily(y,m,d)
            sum = exp.sum(:sum_out)
            if exp.count > 0
              s.day[day.to_s] = [exp.count, sum.round(2)]
              wdy += 1
              out += sum
            end
          end
          s.wdy = wdy; s.out = out.round(2); s.avg = (out / wdy).nan? ? 0.0 : (out / wdy).round(2)
          s.save
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
