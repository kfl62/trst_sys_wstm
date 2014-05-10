# encoding: utf-8
module Wstm
  class PartnerFirm < Trst::Firm

    field :client,              type: Boolean,       default: true
    field :supplr,              type: Boolean,       default: true
    field :transp,              type: Boolean,       default: true
    field :p03,                 type: Boolean,       default: true
    field :firm,                type: Boolean,       default: false

    embeds_many :addresses,   class_name: "Wstm::PartnerFirm::Address", cascade_callbacks: true
    embeds_many :people,      class_name: "Wstm::PartnerFirm::Person",  cascade_callbacks: true
    embeds_many :units,       class_name: "Wstm::PartnerFirm::Unit",    cascade_callbacks: true
    embeds_many :banks,       class_name: "Wstm::PartnerFirm::Bank",    cascade_callbacks: true
    has_many    :dlns_client, class_name: "Wstm::DeliveryNote",       inverse_of: :client
    has_many    :dlns_transp, class_name: "Wstm::DeliveryNote",       inverse_of: :transp
    has_many    :grns_supplr, class_name: "Wstm::Grn",                inverse_of: :supplr
    has_many    :grns_transp, class_name: "Wstm::Grn",                inverse_of: :transp
    has_many    :invs_client, class_name: "Wstm::Invoice",            inverse_of: :client

    accepts_nested_attributes_for :addresses, :people, :units, :banks

    class << self
      # @todo
      def unit_by_unit_id(i)
        find_by(:firm => true).units.find(i)
      end
      # @todo
      def person_by_person_id(i)
        i = Moped::BSON::ObjectId(i) if i.is_a?(String)
        find_by(:'people._id' => i).people.find(i)
      end
      # @todo
      def unit_ids
        find_by(:firm => true).units.asc(:slug).map(&:id)
      end
      # @todo
      def pos(s)
        s = s.upcase
        find_by(:firm => true).units.find_by(:slug => s)
      end
      # @todo
      def auto_search(params)
        if params[:w]
          default_sort.where(params[:w].to_sym => true)
          .and(name: /\A#{params[:q]}/i)
          .each_with_object([]){|pf,a| a << {id: pf.id.to_s,text: "#{pf.name[0][0..20]}"}}
        elsif params[:id]
          find(params[:id]).people.asc(:name_last).each_with_object([]){|d,a| a << {id: d.id.to_s,text: "#{d.name[0..20]}"}}.push({id: 'new',text: 'Adăugare delegat'})
        else
          default_sort.only(:id,:name,:identities)
          .or(name: /\A#{params[:q]}/i)
          .or(:'identities.fiscal' => /\A#{params[:q]}/i)
          .each_with_object([]){|pf,a| a << {id: pf.id.to_s,text: "#{pf.identities['fiscal'].ljust(18)} #{pf.name[1]}"}}
        end
      end
    end # Class methods
    # @todo
    def view_filter
      [id, name[1], identities['fiscal']]
    end
  end # PartnerFirm

  class PartnerFirm::Address < Trst::Address

    field :name,    type: String,   default: 'Main Address'

    embedded_in :firm, class_name: 'Wstm::PartnerFirm', inverse_of: :addresses

  end # FirmAddress
  PartnerFirmAddress = PartnerFirm::Address

  class PartnerFirm::Person < Trst::Person

    field :role,    type: String

    embedded_in :firm,          class_name: 'Wstm::PartnerFirm',  inverse_of: :people
    has_many    :dlns_client,   class_name: 'Wstm::DeliveryNote', inverse_of: :client_d
    has_many    :dlns_transp,   class_name: 'Wstm::DeliveryNote', inverse_of: :transp_d
    has_many    :grns_transp,   class_name: 'Wstm::Grn',          inverse_of: :transp_d
    has_many    :grns_supplr,   class_name: 'Wstm::Grn',          inverse_of: :supplr_d
    has_many    :invs_client,   class_name: 'Wstm::Invoice',      inverse_of: :client_d

  end # FirmPerson
  PartnerFirmPerson = PartnerFirm::Person

  class PartnerFirm::Unit
    include Mongoid::Document
    include Mongoid::Timestamps
    include Trst::ViewHelpers

    field :role,      type: String
    field :name,      type: Array,        default: ['ShortName','FullName']
    field :slug,      type: String
    field :chief,     type: String,       default: 'Lastname Firstname'
    field :env_auth,  type: String
    field :trn_auth,  type: String
    field :main,      type: Boolean,      default: false

    embedded_in :firm,      class_name: 'Wstm::PartnerFirm',  inverse_of: :units
    has_many    :users,     class_name: 'Wstm::User',         inverse_of: :unit
    has_many    :freights,  class_name: 'Wstm::Freight',      inverse_of: :unit
    has_many    :dps,       class_name: 'Wstm::Cache',        inverse_of: :unit
    has_many    :apps,      class_name: 'Wstm::Expenditure',  inverse_of: :unit
    has_many    :stks,      class_name: 'Wstm::Stock',        inverse_of: :unit
    has_many    :dlns,      class_name: 'Wstm::DeliveryNote', inverse_of: :unit
    has_many    :grns,      class_name: 'Wstm::Grn',          inverse_of: :unit
    has_many    :csss,      class_name: 'Wstm::Cassation',    inverse_of: :unit
    has_many    :srts,      class_name: 'Wstm::Sorting',      inverse_of: :unit

    # @todo
    def view_filter
      [id, name[1]]
    end
    # @todo
    def stock_now
      stks.find_by(id_date: Date.new(2000,1,31))
    end
    # @todo
    def stock_monthly(y,m)
      if m == 12
        y,m = y + 1, 1
      else
        m = m + 1
      end
      stks.find_by(id_date: Date.new(y,m,1))
    end
    # @todo
    def stock_create(y,m)
      stk_new = stks.create(
        id_date: Date.new(y,m,1),
        name: "Stock_#{slug}_#{I18n.localize(Date.new(y,m,1), format: '%Y-%m')}",
        expl: "Stoc initial #{I18n.localize(Date.new(y,m,1), format: '%B, %Y').downcase}"
      )
      self.stock_now.freights.where(:qu.ne => 0).each{|f| stk_new.freights << f.clone}
      stk_new.freights.each{|f| f.set(:id_date,stk_new.id_date)}
      stk_new
    end
    # @todo
    def active?(y,m)
      a = apps.monthly(y,m).first.freights.sum(:qu).round(2) > 0 rescue false
      s = stks.monthly(y,m).first.freights.sum(:qu).round(2) > 0 rescue false
      d = dlns.monthly(y,m).first.freights.sum(:qu).round(2) > 0 rescue false
      g = grns.monthly(y,m).first.freights.sum(:qu).round(2) > 0 rescue false
      c = csss.monthly(y,m).first.freights.sum(:qu).round(2) > 0 rescue false
      o = srts.monthly(y,m).first.freights.sum(:qu).round(2) > 0 rescue false
      a || s || d || g || c || o
    end
    # @todo
    def yearly_stats(y)
      s = freights.asc(:id_stats).each_with_object({}){|f,h| h[f.id_stats] = [f.name]}
      (1..12).each do |i|
        data  = apps.monthly(y,i).pluck(:_id)
        Wstm::FreightIn.where(:doc_exp_id.in => data).asc(:id_stats).each do |f|
          s[f.id_stats][i].nil? ? s[f.id_stats][i] = f.qu : s[f.id_stats][i] += f.qu
        end
      end
      s.each_pair do |k,v|
        v.count < 13 ? v[12] = 0 : v
        v.map! { |x| x || 0 }
        v[13] = v[1..13].inject(:+)
        v[14] = v[13] / v[1..12].count{|x| x != 0}.to_f
        v.map! { |x| x.round(2) rescue x}
      end
    end
  end # FirmUnit
  PartnerFirmUnit = PartnerFirm::Unit

  class PartnerFirm::Bank
    include Mongoid::Document
    include Mongoid::Timestamps
    include Trst::ViewHelpers

    field :name,      type: String
    field :swift,     type: String

    embedded_in :firm,      class_name: 'Wstm::PartnerFirm',  inverse_of: :banks

    # @todo
    # def view_filter
    #   [id, name[1]]
    # end
  end # FirmBank
  PartnerFirmBank = PartnerFirm::Bank
end # Wstm
