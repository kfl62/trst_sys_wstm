define () ->
  $.extend true,Wstm,
    desk:
      payment:
        init: ()->
          $log 'Wstm.desk.payment.init() OK...'
  Wstm.desk.payment
