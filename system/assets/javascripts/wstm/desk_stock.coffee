define () ->
  $.extend true,Wstm,
    desk:
      stock:
        init: ()->
          $log 'Wstm.desk.stock.init() OK...'
  Wstm.desk.stock
