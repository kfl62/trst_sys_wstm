# encoding: utf-8
module Wstm
  class FreightStock
    include Mongoid::Document
    include Mongoid::Timestamps
    include Trst::ViewHelpers
    include Trst::DateHelpers

    field :id_date,     type: Date
    field :id_stats,    type: String
    field :id_intern,   type: Boolean,   default: false
    field :um,          type: String,    default: "kg"
    field :pu,          type: Float,     default: 0.00
    field :qu,          type: Float,     default: 0.00
    field :val,         type: Float,     default: 0.00

    belongs_to  :freight,  class_name: 'Wstm::Freight',     inverse_of: :stocks
    belongs_to  :doc,      class_name: 'Wstm::Stock',       inverse_of: :freights

    class << self
    end # Class methods

  end # FreightIn
end # Wstm
