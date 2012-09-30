# encoding: utf-8
module Wstm
  class PartnerFirm < Trst::Firm

    field :client,              type: Boolean,       default: true
    field :supplr,              type: Boolean,       default: true
    field :transp,              type: Boolean,       default: true
    field :p03,                 type: Boolean,       default: true
    field :firm,                type: Boolean,       default: false

    embeds_many :addresses,   class_name: "Wstm::PartnerFirmAddress", cascade_callbacks: true
    embeds_many :people,      class_name: "Wstm::PartnerFirmPerson",  cascade_callbacks: true
    embeds_many :units,       class_name: "Wstm::PartnerFirmUnit",    cascade_callbacks: true
    has_many    :dlns_client, class_name: "Wstm::DeliveryNote",       inverse_of: :client
    has_many    :dlns_transp, class_name: "Wstm::DeliveryNote",       inverse_of: :transp
    has_many    :grns_supplr, class_name: "Wstm::Grn",                inverse_of: :supplr
    has_many    :grns_transp, class_name: "Wstm::Grn",                inverse_of: :transp
    has_many    :invs_client, class_name: "Wstm::Invoice",            inverse_of: :client

    accepts_nested_attributes_for :addresses, :people, :units

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

  class PartnerFirmAddress < Trst::Address

    field :name,    type: String,   default: 'Main Address'

    embedded_in :firm, class_name: 'Wstm::PartnerFirm', inverse_of: :addresses

  end # FirmAddress

  class PartnerFirmPerson < Trst::Person

    field :role,    type: String

    embedded_in :firm,          class_name: 'Wstm::PartnerFirm',  inverse_of: :people
    has_many    :dlns_client,   class_name: 'Wstm::DeliveryNote', inverse_of: :client_d
    has_many    :dlns_transp,   class_name: 'Wstm::DeliveryNote', inverse_of: :transp_d
    has_many    :grns_transp,   class_name: 'Wstm::Grn',          inverse_of: :transp_d
    has_many    :grns_supplr,   class_name: 'Wstm::Grn',          inverse_of: :supplr_d
    has_many    :invs_client,   class_name: 'Wstm::Invoice',      inverse_of: :client_d

  end # FirmPerson

  class PartnerFirmUnit
    include Mongoid::Document
    include Mongoid::Timestamps
    include Trst::ViewHelpers

    field :role,      type: String
    field :name,      type: Array,        default: ['ShortName','FullName']
    field :slug,      type: String
    field :chief,     type: String,       default: 'Lastname Firstname'
    field :env_auth,  type: String
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
      stks.find_by(id_date: Date.new(y,m + 1,1))
    end
  end # FirmUnit
end # Wstm
