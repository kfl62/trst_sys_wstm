# encoding: utf-8
module Wstm
  class PartnerPerson < Trst::Person
    has_one :address,  class_name:  'Trst::Address', as: :person_address
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
end # Wstm
