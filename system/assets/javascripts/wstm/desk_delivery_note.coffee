define () ->
  $.extend true,Wstm,
    desk:
      delivery_note:
        calculate: ()->
          $rows  = $('tr.freight')
          $total = $('tr.total')
          tot_qu = 0
          $rows.each ()->
            $tr = $(@)
            $sd = $tr.find('select').find('option:selected').data()
            stck= parseFloat($tr.find('span.stck').text())
            qu  = parseFloat($tr.find('input[name*="qu"]').decFixed(2).val())
            res = (stck - qu).round(2)
            if res < 0
              alert Trst.i18n.msg.delivery_note_negative_stock
                    .replace '%{stck}', stck.toFixed(2)
                    .replace '%{res}',  (0 - res).toFixed(2)
              qu  = stck; res = 0
              $tr.find('input[name*="qu"]').val(qu).decFixed(2)
            tot_qu += qu
            $tr.find('span.res').text(res.toFixed(2))
            return
          $total.find('span.res').text(tot_qu.toFixed(2))
          return
        validate:
          filter: ()->
            if $('#client_id').val() isnt '' and $('#transporter_id').val() isnt '' and $('#transp_d_id').val() isnt '' and $('#transp_d_id').val() isnt 'new'
              $url = Trst.desk.hdf.attr('action')
              $url += "?client_id=#{$('#client_id').val()}"
              $url += "&transp_id=#{$('#transp_id').val()}"
              $url += "&transp_d_id=#{$('#transp_d_id').val()}"
              $url += "&client_d_id=#{$('#client_d_id').val()}" if $('#client_d_id').val() isnt '' and $('#client_d_id').val() isnt 'new'
              $('button.dn').data('url', $url)
              $('button.dn').button 'option', 'disabled', false
            else
              $('button.dn').button 'option', 'disabled', true
            return
          create: ()->
            if (/[A-Z]{3}-$/).test($('input[name*="doc_name"]').val()) or $('input[name*="doc_name"]').val() is '' or $('input[name*="doc_plat"]').val() is ''
              alert Trst.i18n.msg.delivery_note_not_complete
              return false
            else
              $('button[data-action="save"]').button 'option', 'disabled', false
              return true
        select: (slcts)->
          slcts.each ()->
            $select = $(@)
            $sd = $select.data()
            $id = $select.attr('id')
            if $select.hasClass 'select2'
              if $id in ['client_id','transp_id']
                $ph = Trst.i18n.select[Trst.desk.hdo.js_ext][$sd.ph]
                $select.select2
                  placeholder: $ph
                  minimumInputLength: $sd.minlength
                  allowClear: true
                  ajax:
                    url: "/utils/search/#{$sd.search}"
                    dataType: 'json'
                    quietMillis: 100
                    data: (term)->
                      w: $id.split('_')[0]
                      q: term
                    results: (data)->
                      results: data
                $select.unbind()
                $select.on 'change', ()->
                  if $select.select2('data')
                    $select.next().select2('data',null)
                    $select.next().select2('destroy')
                    $dlg   = $select.next()
                    $dlgsd = $dlg.data()
                    $dlgph = Trst.i18n.select[Trst.desk.hdo.js_ext][$dlgsd.ph]
                    $dlg.select2
                      placeholder: $dlgph
                      minimumInputLength: $dlgsd.minlength
                      allowClear: true
                      ajax:
                        url: "/utils/search/#{$sd.search}"
                        dataType: 'json'
                        data: (term)->
                          id: $select.select2('val')
                        results: (data)->
                          results: data
                    $dlg.unbind()
                    $dlg.on 'change', ()->
                      if $dlg.select2('data')
                        if $dlg.select2('data').id is 'new'
                          $dlgadd = $dlg.next()
                          $dlgadd.data('url','/sys/wstm/partner_firm_person')
                          $dlgadd.data('r_id',$select.select2('val'))
                          $dlgadd.data('r_mdl','firm')
                          $dlgadd.show()
                        else
                          $dlg.next().hide()
                      else
                        $dlg.next().hide()
                      Wstm.desk.delivery_note.validate.filter()
                  else
                    $select.next().select2('data',null)
                    $select.next().select2('destroy')
                    $select.next().next().hide()
                  Wstm.desk.delivery_note.validate.filter()
            else if $select.hasClass 'freight'
              $select.on 'change', ()->
                if Wstm.desk.delivery_note.validate.create()
                  $sod = $select.find('option:selected').data()
                  $inp = $select.parentsUntil('tbody').last().find('input')
                  $stck= $select.parentsUntil('tbody').last().find('span.stck')
                  $inp.filter('[name*="freight_id"]').val($select.val())
                  $inp.filter('[name*="id_date"]').val($('#date_send').val())
                  $inp.filter('[name*="id_stats"]').val($sod.id_stats)
                  $inp.filter('[name*="um"]').val($sod.um)
                  $stck.text(parseFloat($sod.stck).toFixed(2))
                  qu = $inp.filter('[name*="qu"]').val('0.00')
                  qu.on 'change', ()->
                    Wstm.desk.delivery_note.calculate()
                  Wstm.desk.delivery_note.calculate()
                  qu.focus().select()
                else
                  $select.val('null')
                return
            else if $select.hasClass 'wstm'
              ###
              Handled by Wstm.desk.select
              ###
            else
              $log 'Select not handled!'
          return
        buttons: (btns)->
          btns.each ()->
            $button = $(@)
            $bd = $button.data()
            $id = $button.attr('id')
            if Trst.desk.hdo.dialog is 'filter'
              if $id in ['client_d','transp_d']
                $button.hide()
              if $bd.action is 'create'
                $button.button 'option', 'disabled', true unless $id
            else if Trst.desk.hdo.dialog is 'create'
              if $bd.action is 'save'
                $button.button 'option', 'disabled', true
                $button.data('remove',false)
                $button.off 'click', Trst.desk.buttons.action.save
                $button.on  'click', Wstm.desk.delivery_note.calculate
                $button.on  'click', Trst.desk.buttons.action.save
            else if Trst.desk.hdo.dialog is 'show'
              if $bd.action is 'print'
                $button.on 'click', ()->
                  Trst.msgShow Trst.i18n.msg.report.start
                  $.fileDownload "/sys/wstm/delivery_note/print?id=#{Trst.desk.hdo.oid}",
                    successCallback: ()->
                      Trst.msgHide()
                    failCallback: ()->
                      Trst.msgHide()
                      Trst.desk.downloadError Trst.desk.hdo.model_name
                  false
            else
              ###
              Buttons default handler Trst.desk.buttons
              ###
          $('span.row-remove').each ()->
            $button = $(@)
            $button.on 'click', ()->
              $button.parentsUntil('tbody').last().remove()
              Wstm.desk.delivery_note.calculate()
              return
            return
          return
        init: ()->
          if $('#date_show').length
            now = new Date()
            min = if Trst.lst.admin is 'true' then new Date(now.getFullYear(),now.getMonth() - 1,1) else new Date(now.getFullYear(),now.getMonth(),1)
            $('#date_show').datepicker 'option', 'maxDate', '+0'
            $('#date_show').datepicker 'option', 'minDate', min
          Wstm.desk.delivery_note.buttons($('button'))
          Wstm.desk.delivery_note.select($('select.wstm, input.select2'))
          $log 'Wstm.desk.delivery_note.init() OK...'
  Wstm.desk.delivery_note
