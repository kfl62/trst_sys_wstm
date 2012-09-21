define () ->
  $.extend true,Wstm,
    desk:
      delivery_note:
        init: ()->
          $log 'Wstm.desk.dnote.init() OK...'
  Wstm.desk.delivery_note
