# encoding: utf-8
module Wstm
  class Expenditure
    include Mongoid::Document
    include Mongoid::Timestamps
    include Trst::ViewHelpers
    include Trst::DateHelpers

    field :name,        type: String
    field :id_date,     type: Date,     default: -> {Date.today}
    field :id_intern,   type: Boolean,  default: false
    field :sum_003,     type: Float,    default: 0.00
    field :sum_016,     type: Float,    default: 0.00
    field :sum_100,     type: Float,    default: 0.00
    field :sum_out,     type: Float,    default: 0.00

    alias :file_name :name

    has_many   :freights,   class_name: "Wstm::FreightIn",       inverse_of: :doc_exp, dependent: :destroy
    belongs_to :client,     class_name: "Wstm::PartnerPerson",   inverse_of: :apps
    belongs_to :unit,       class_name: "Wstm::PartnerFirmUnit", inverse_of: :apps
    belongs_to :signed_by,  class_name: "Wstm::User",            inverse_of: :apps

    accepts_nested_attributes_for :freights,
      reject_if: ->(attrs){ attrs[:qu].to_i == 0 }

    class << self
      # @todo
      def pos(s)
        where(unit_id: Wstm::PartnerFirm.pos(s).id)
      end
      # @todo
      def to_txt
        all.asc(:name).each{|app| p "#{app.name} --- #{app.id_date.to_s} #{app.updated_at.strftime("%H:%M")} --- #{("%.2f" % app.sum_out).rjust(8)}"}
      end
    end # Class methods

    # @todo
    def unit
      Wstm::PartnerFirm.unit_by_unit_id(unit_id) rescue nil
    end
    # @todo
    def increment_name(unit_id)
      apps = Wstm::Expenditure.yearly(Date.today.year).where(unit_id: unit_id)
      if apps.count > 0
        name = apps.asc(:name).last.name.next
      else
        apps = Wstm::Expenditure.where(unit_id: unit_id)
        unit = Wstm::PartnerFirm.unit_by_unit_id(unit_id)
        if apps.count > 0
          prefix = apps.asc(:name).last.name.split('-').last[0].next
          name = "#{unit.firm.name[0][0..2].upcase}_#{unit.slug}-#{prefix}00001"
        else
          name = "#{unit.firm.name[0][0..2].upcase}_#{unit.slug}-000001"
        end
      end
      name
    end
  end # Expenditure
end #Wstm
