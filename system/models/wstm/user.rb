# encoding: utf-8
module Wstm
  class User < Trst::User
    belongs_to :unit,     class_name: 'Wstm::PartnerFirmUnit', inverse_of: :users

    class << self
    end # Class methods

    #todo
    def unit
      Wstm::PartnerFirm.unit_by_unit_id(unit_id) rescue nil
    end
  end # User
end # Wstm
