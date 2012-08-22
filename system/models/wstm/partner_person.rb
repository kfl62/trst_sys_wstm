# encoding: utf-8
module Wstm
  class PartnerPerson < Trst::Person
    embeds_one :address,  class_name:  'Wstm::PartnerPersonAddress', cascade_callbacks: true
    accepts_nested_attributes_for :address

    class << self
      def default_sort
        asc(:name_last,:name_frst)
      end
    end # Class methods
    # @todo
    def view_filter
      [id, name, id_pn]
    end
  end # PartnerPerson

  class PartnerPersonAddress < Trst::Address

    field :name,    type: String,   default: 'Domiciliu'

    embedded_in :partner_person , class_name: 'Wstm::PartnerPerson', inverse_of: :address

  end # PartnerPersonAddress
end # Wstm
