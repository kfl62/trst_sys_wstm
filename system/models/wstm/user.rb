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

    #todo
    def unit
      Wstm::PartnerFirm.unit_by_unit_id(unit_id) rescue nil
    end
  end # User
end # Wstm
