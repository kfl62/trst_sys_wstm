# encoding: utf-8
module Wstm
  module Hmrs
    class Employee < Trst::Person
      field :other,       type: String, default: 'Employee'

      embeds_one  :address,   class_name: 'Wstm::Hmrs::EmployeeAddress', cascade_callbacks: true
      embeds_one  :ilc,       class_name: 'Wstm::Hmrs::EmployeeIlc', cascade_callbacks: true
      embeds_many :addendums, class_name: 'Wstm::Hmrs::EmployeeAddendum', cascade_callbacks: true

      validates_uniqueness_of :id_pn, :unless => Proc.new{|p| p.id_pn == '-'}

      accepts_nested_attributes_for :address, :ilc, :addendums

      class << self
      end # Class methods

      alias :file_name :name

      # @todo
      def view_filter
        [id, name, id_pn]
      end
      # @todo
      def i18n_hash
        {
          id_pn: id_pn, name: name,
          city: address.city, street: address.street, nr: address.nr, bl: address.bl, sc: address.sc, et: address.et, ap: address.ap,
          dsr: id_doc["sr"], dnr: id_doc["nr"], dby: id_doc["by"], don: id_doc["on"]
        }
      end
    end # Employee

    class EmployeeAddress < Trst::Address
      field :name,    type: String,   default: 'Domiciliu'

      embedded_in :employee, class_name: 'Wstm::Hmrs::Employee', inverse_of: :address
    end # EmployeeAddress

    class EmployeeIlc
      include Mongoid::Document
      include Mongoid::Timestamps

      field :objct,   type: String,     default: 'Manipulare marfă'
      field :name,    type: String,     default: "xxx / #{Date.today.to_s}"
      field :start,   type: Date,       default: -> {Date.today}
      field :drtn,    type: Integer,    default: 0
      field :wrkplc,  type: String,     default: 'Depozit'
      field :cor,     type: String,     default: '933005 - Manipulant'
      field :wrkhrs,  type: Integer,    default: 8
      field :wrkprg,  type: String,     default: '7 - 15'
      field :lieve,   type: Integer,    default: 21
      field :slry,    type: Integer,    default: 1150
      field :pydys,   type: String,     default: '30 a lunii în curs şi 15 a lunii următoare'
      field :prbtn,   type: Integer,    default: 90
      field :pdmss,   type: Integer,    default: 20
      field :prsgn,   type: Integer,    default: 20
      field :ccm,     type: String,     default: '-'

      embedded_in :employee, class_name: 'Wstm::Hmrs::Employee', inverse_of: :ilc
    end # EmployeeIlc

    class EmployeeAddendum
      include Mongoid::Document
      include Mongoid::Timestamps

      field :name,    type: String,     default: "xxx / #{Date.today.to_s}"

      embedded_in :employee, class_name: 'Wstm::Hmrs::Employee', inverse_of: :addendums
    end
  end # Hmrs
end # Wstm
