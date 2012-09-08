define () ->
  $.extend true,Wstm,
    desk:
      idPnHandle: ()->
        $input = $('input[name*="id_pn"]')
        if Wstm.desk.idPnValidate($input.val())
          $input.attr('class','ui-state-default')
          $input.parents('tr').next().find('input').focus()
        else
          $input.attr('class','ui-state-error').focus()
        return
      idPnValidate: (id)->
        $chk = "279146358279"
        $sum = 0
        for i in [0..12]
          do (i)->
            $sum += id.charAt(i) * $chk.charAt(i)
        $mod = $sum % 11
        if ($mod < 10 and $mod.toString() is id.charAt(12)) or ($mod is 10 and id.charAt(12) is "1")
          true
        else
          false
      init: () ->
        if $('select.wstm, input.select2').length
          require (['wstm/desk_select']), ()->
            Wstm.desk.select.init()
        if $('#date_show').length
          $('#date_show').datepicker
            altField: '#date_send'
            altFormat: 'yy-mm-dd'
            autoSize: true
            $.datepicker.regional['ro']
        $model = Trst.desk.hdf.attr('action').split('/').pop(-1)
        if $model is 'expenditure'
          require (['wstm/desk_expenditure']), ()->
            Wstm.desk.expenditure.init()
        if $('input[name*="id_pn"]').length
          if Trst.desk.hdo.dialog is 'create' or Trst.desk.hdo.dialog is 'edit'
            Wstm.desk.idPnHandle()
          $('input[name*="id_pn"]').on 'keyup', ()->
            Wstm.desk.idPnHandle()
        $msg 'Wstm.desk.init() Ok...'
  Wstm
