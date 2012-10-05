define () ->
  $.extend true,Wstm,
    desk:
      tmp:
        set: (key,value)->
          if @[key] or @[key] is 0 then @[key] else @[key] = value
        clear: ()->
          $.each @, (k)=>
            delete @[k] unless k in ['set','clear']
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
        if $('#date_show').length
          $dsh = $('#date_show')
          $dsh.datepicker
            altField: '#date_send'
            altFormat: 'yy-mm-dd'
            $.datepicker.regional['ro']
          $dsh.addClass('ce').attr 'size', $dsh.val().length + 2
          $dsh.on 'change', ()->
            $dsh.attr 'size', $dsh.val().length + 2
            return
        if $('input.id_intern').length
          $id_intern = $('input[name*="\[name\]"]')
          $id_intern.attr 'size', $id_intern.val().length + 4
          $id_intern.on 'change', ()->
            $id_intern.attr 'size', $id_intern.val().length + 4
            return
        if Trst.desk.hdo.dialog is 'create' or Trst.desk.hdo.dialog is 'edit'
          if $('input[name*="id_pn"]').length
            Wstm.desk.idPnHandle()
            $('input[name*="id_pn"]').on 'keyup', ()->
              Wstm.desk.idPnHandle()
          $('input.focus').focus()
          $('select.focus').focus()
        $log 'Wstm.desk.init() Ok...'
        if $('select.wstm, input.select2').length
          require (['wstm/desk_select']), (select)->
            select.init()
        if $ext = Trst.desk.hdo.js_ext
          require (["wstm/#{$ext}"]), (ext)->
            ext.init()
        return
  Wstm.desk
