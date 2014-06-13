# encoding: utf-8

module Wstm
  class Sorting < Trst::Sorting

    has_many   :from_freights, class_name: "Wstm::FreightOut",          inverse_of: :doc_sor, dependent: :destroy
    has_many   :resl_freights, class_name: "Wstm::FreightIn",           inverse_of: :doc_sor, dependent: :destroy
    belongs_to :unit,          class_name: "Wstm::PartnerFirm::Unit",   inverse_of: :srts
    belongs_to :signed_by,     class_name: "Wstm::User",                inverse_of: :srts

    alias :file_name :name; alias :unit :unit_belongs_to

    accepts_nested_attributes_for :from_freights,
      reject_if: ->(attrs){ attrs[:qu].to_f == 0 }
    accepts_nested_attributes_for :resl_freights,
      reject_if: ->(attrs){ attrs[:qu].to_f == 0 }

    after_save  :handle_freights

    class << self
    end # Class methods

    protected
    # @todo
    def handle_freights
      from_freights.each{|f| f.set(:id_intern,true); f.set(:val,(f.pu * f.qu).round(2))}
      resl_freights.each{|f| f.set(:id_intern,true); f.set(:val,(f.pu * f.qu).round(2))}
    end
  end # Sorting
end # Wstm
