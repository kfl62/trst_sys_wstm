# encoding: utf-8
module Wstm
  class CacheBook < Trst::CacheBook

    embeds_many :lines,       class_name: 'Wstm::CacheBook::Line',        cascade_callbacks: true

  end # CacheBook

  class CacheBook::Line < Trst::CacheBookLine

    embedded_in :cb,          class_name: 'Wstm::CacheBook',            inverse_of: :lines

  end # CacheBookIn
  Wstm::CacheBookIn = Wstm::CacheBook::Line
end #Wstm
