define () ->
  $.extend true,Wstm,
    desk:
      tmp:
        set: (key,value)->
          if @[key] or @[key] is 0 then @[key] else @[key] = value
        clear: (what...)->
          $.each @, (k)=>
            if what.length
              delete @[k] if k in [what...]
            else
              delete @[k] unless k in ['set','clear']
      scrollHeader: (tbl,h=450)->
        $table = $(tbl)
        if h isnt 0
          tblHdr   = $("<table style='width:auto'><tbody class='inner'><tr></tr><tr></tr></tbody></table>")
          tblCntnr = $("<div id='scroll-container' style='height:#{h}px;overflow-x:hidden;overflow-y:scroll'></div>")
          tblClmnW = []
          $table.find('tr.scroll td').each (i)->
            tblClmnW[i] = $(this).width()
            return
          tblscrll = $table.find('tr.scroll').html()
          $table.find('tr.scroll').html('')
          $table.css('width','auto')
          tblHdr.find('tr:first').html(tblscrll)
          tblHdr.find('tr:first td').each (i)->
            $(this).css('width', tblClmnW[i])
            return
          $table.find('tr.scroll').next().find('td').each (i)->
            $(this).css('width', tblClmnW[i])
            return
          $table.before(tblHdr)
          $table.wrap(tblCntnr)
        else
          tblscrll = $('div#scroll-container').prev().find('tr:first').html()
          $('div#scroll-container').prev().remove()
          $table.find('tr.scroll').html(tblscrll)
          $table.unwrap()
        return
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
      datePicker: (node)->
        $datepicker = $(node)
        now = new Date()
        min = if Trst.lst.admin is 'true' then new Date(now.getFullYear(),now.getMonth() - 1,1) else new Date(now.getFullYear(),now.getMonth(),1)
        max = if Trst.lst.admin is 'true' then '+1' else '+0'
        $datepicker.datepicker
          altField: '#date_send'
          altFormat: 'yy-mm-dd'
          maxDate: max
          minDate: min
          regional: ['ro']
        $datepicker.addClass('ta-ce').attr 'size', $datepicker.val()?.length + 2
        $datepicker.on 'change', ()->
          $datepicker.attr 'size', $datepicker.val()?.length + 2
          return
        return
      init: () ->
        @datePicker $('#date_show')
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
        if $('table.scroll').height() > 450
          Wstm.desk.scrollHeader($('table.scroll'))
        $log 'Wstm.desk.init() Ok...'
        if $('select.wstm, input.select2').length
          require (['wstm/desk_select']), (select)->
            select.init()
        if $ext = Trst.desk.hdo.js_ext
          require (["wstm/#{$ext}"]), (ext)->
            ext.init()
        return
  Wstm.desk
