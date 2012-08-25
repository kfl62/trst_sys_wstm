# encoding: utf-8
module Wstm
  class FreightOut
    include Mongoid::Document
    include Mongoid::Timestamps
    include Trst::ViewHelpers

    field :id_date,     type: Date
    field :id_stats,    type: String
    field :id_intern,   type: Boolean,   default: false
    field :um,          type: String,    default: "kg"
    field :pu,          type: Float,     default: 0.00
    field :pu_invoice,  type: Float,     default: 0.00
    field :qu,          type: Float,     default: 0.00
    field :val,         type: Float,     default: 0.00
    field :val_invoice, type: Float,     default: 0.00

    belongs_to  :freight,  class_name: 'Wstm::Freight', inverse_of: :outs

    class << self
    end # Class methods

  end # User
end # Wstm
