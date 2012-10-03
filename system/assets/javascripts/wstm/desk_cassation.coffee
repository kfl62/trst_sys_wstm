define () ->
  $.extend true,Wstm,
    desk:
      cassation:
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
              alert Trst.i18n.msg.cassation_negative_stock
                    .replace '%{stck}', stck.toFixed(2)
                    .replace '%{res}',  (0 - res).toFixed(2)
              qu  = stck; res = 0
              $tr.find('input[name*="qu"]').val(qu).decFixed(2)
            tot_qu += qu
            $tr.find('span.res').text(res.toFixed(2))
            return
          $total.find('span.res').text(tot_qu.toFixed(2))
          if tot_qu > 0
            $('button[data-action="save"]').button 'option', 'disabled', false
          else
            $('button[data-action="save"]').button 'option', 'disabled', true
          return
        inputs: (inpts)->
          inpts.each ()->
            $input = $(@)
            if $input.attr('id') is 'date_show'
              $input.on 'change', ()->
                if Trst.desk.hdo.dialog is 'create'
                  $('input[name*="id_date"]').each ()->
                    $(@).val($('#date_send').val()) unless $(@).val() is ''
                    return
                if Trst.desk.hdo.dialog is 'repair'
                  Wstm.desk.cassation.selects($('input.repair'))
              return
          return
        selects: (slcts)->
          slcts.each ()->
            $select = $(@)
            $sd = $select.data()
            $id = $select.attr('id')
            if $select.hasClass 'freight'
              $select.on 'change', ()->
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
                  Wstm.desk.cassation.calculate()
                Wstm.desk.cassation.calculate()
                qu.focus().select()
                return
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
            if Trst.desk.hdo.dialog is 'create'
              if $bd.action is 'save'
                $button.button 'option', 'disabled', true
                $button.data('remove',false)
                $button.off 'click', Trst.desk.buttons.action.save
                $button.on  'click', Wstm.desk.cassation.calculate
                $button.on  'click', Trst.desk.buttons.action.save
            else if Trst.desk.hdo.dialog is 'show'
              if $bd.action is 'print'
                $button.on 'click', ()->
                  Trst.msgShow Trst.i18n.msg.report.start
                  $.fileDownload "/sys/wstm/cassation/print?id=#{Trst.desk.hdo.oid}",
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
          $('span.icon-remove-sign').each ()->
            $button = $(@)
            $button.on 'click', ()->
              $button.parentsUntil('tbody').last().remove()
              Wstm.desk.cassation.calculate()
              return
            return
          return
        init: ()->
          if $('#date_show').length
            now = new Date()
            min = if Trst.lst.admin is 'true' then new Date(now.getFullYear(),now.getMonth() - 1,1) else new Date(now.getFullYear(),now.getMonth(),1)
            $('#date_show').datepicker 'option', 'maxDate', '+0'
            $('#date_show').datepicker 'option', 'minDate', min
          Wstm.desk.cassation.buttons($('button'))
          Wstm.desk.cassation.selects($('select.wstm'))
          Wstm.desk.cassation.inputs($('input'))
          $log 'Wstm.desk.cassation.init() OK...'
  Wstm.desk.cassation
