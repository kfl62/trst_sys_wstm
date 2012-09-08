# encoding: utf-8
module Wstm
  class PartnerFirm < Trst::Firm
    field :client,              type: Boolean,       default: true
    field :supplier,            type: Boolean,       default: true
    field :transporter,         type: Boolean,       default: true
    field :p03,                 type: Boolean,       default: true
    field :firm,                type: Boolean,       default: false

    embeds_many :addresses,   class_name: "Wstm::PartnerFirmAddress", cascade_callbacks: true
    embeds_many :people,      class_name: "Wstm::PartnerFirmPerson",  cascade_callbacks: true
    embeds_many :units,       class_name: "Wstm::PartnerFirmUnit",    cascade_callbacks: true
    accepts_nested_attributes_for :addresses, :people, :units

    class << self
      # @todo
      def unit_by_unit_id(i)
        find_by(:firm => true).units.find(i)
      end
      # @todo
      def unit_ids
        find_by(:firm => true).units.asc(:slug).map{|u| u.id}
      end
      # @todo
      def pos(s)
        s = s.upcase
        find_by(:firm => true).units.find_by(:slug => s)
      end
      # @todo
      def auto_search(params)
        default_sort.only(:id,:name,:identities)
        .or(name: /\A#{params[:q]}/i)
        .or(:'identities.fiscal' => /\A#{params[:q]}/i)
        .each_with_object([]){|pf,a| a << {id: pf.id.to_s,text: "#{pf.identities['fiscal'].ljust(18)} #{pf.name[1]}"}}
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

    embedded_in :firm, class_name: 'Wstm::PartnerFirm', inverse_of: :people

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
    has_many    :stocks,    class_name: 'Wstm::Stock',        inverse_of: :unit

    # @todo
    def view_filter
      [id, name[1]]
    end
  end # FirmUnit
end # Wstm
