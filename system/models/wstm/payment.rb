# encoding: utf-8
module Wstm
  class Payment < Trst::Payment

    belongs_to :doc_inv,      class_name: "Wstm::Invoice",              inverse_of: :pyms

    class << self
    end # Class methods

  end # Payment
end # Wstm
