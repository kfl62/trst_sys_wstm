define () ->
  $.extend true,Wstm,
    desk:
      sorting:
        init: ()->
          if $('#date_show').length
            now = new Date()
            min = if Trst.lst.admin is 'true' then new Date(now.getFullYear(),now.getMonth() - 1,1) else new Date(now.getFullYear(),now.getMonth(),1)
            $('#date_show').datepicker 'option', 'maxDate', '+0'
            $('#date_show').datepicker 'option', 'minDate', min
          #Wstm.desk.sorting.buttons($('button'))
          #Wstm.desk.sorting.selects($('select.wstm'))
          #Wstm.desk.sorting.inputs($('input'))
          $log 'Wstm.desk.sorting.init() OK...'
  Wstm.desk.sorting
