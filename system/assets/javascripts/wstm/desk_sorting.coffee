define () ->
  $.extend true,Wstm,
    desk:
      sorting:
        calculate: (fromFreight = false)->
          $rows  = $('tr.resl-freight')
          $total = $('tr.total')
          tot_qu = 0
          if fromFreight is true
            $('select.resl-freight').val('null')
            $('select.resl-freight').change()
            total_qu = 0
          else
            $rows.each ()->
              $tr = $(@)
              $sd = $tr.find('select').find('option:selected').data()
              qu  = parseFloat($tr.find('input[name*="qu"]').decFixed(2).val())
              tot_qu += qu
              $('#from-freight-qu').text(tot_qu.toFixed(2))
              $('#from-freight-qu-submit').val(tot_qu.toFixed(2))
          $('#from-freight-stock').text(($('select.from-freight').find('option:selected').data().stck - parseFloat($('#from-freight-qu-submit').decFixed(2).val())).toFixed(2))
          $total.find('span.res').text(tot_qu.toFixed(2))
          if tot_qu > 0
            $('button[data-action="save"]').button 'option', 'disabled', false
          else
            $('button[data-action="save"]').button 'option', 'disabled', true
          return
        selects: (slcts)->
          slcts.each ()->
            $select = $(@)
            $sd = $select.data()
            if $select.hasClass 'resl-freight'
              $select.on 'change', ()->
                $sod = $select.find('option:selected').data()
                $inp = $select.parentsUntil('tbody').last().find('input')
                $inp.filter('[name*="freight_id"]').val($select.val())
                $inp.filter('[name*="id_date"]').val($('#date_send').val())
                $inp.filter('[name*="id_stats"]').val($sod.id_stats)
                $inp.filter('[name*="um"]').val($sod.um)
                $inp.filter('[name*="pu"]').val(parseFloat($('select.from-freight').find('option:selected').data().pu).toFixed(2))
                qu = $inp.filter('[name*="qu"]').val('0.00')
                qu.on 'change', ()->
                  Wstm.desk.sorting.calculate()
                Wstm.desk.sorting.calculate()
                qu.focus().select()
                return
              return
            else if $select.hasClass 'from-freight'
              $select.on 'change', ()->
                $sod = $select.find('option:selected').data()
                $inp = $select.parentsUntil('thead').next('tr').find('input')
                $inp.filter('[name*="freight_id"]').val($select.val())
                $inp.filter('[name*="id_date"]').val($('#date_send').val())
                $inp.filter('[name*="id_stats"]').val($sod.id_stats)
                $inp.filter('[name*="um"]').val($sod.um)
                $inp.filter('[name*="qu"]').val('0.00')
                $inp.filter('[name*="pu"]').val(parseFloat($sod.pu).toFixed(2))
                $('#from-freight-stock').text(parseFloat($sod.stck).toFixed(2))
                if $select.val() is 'null' then $('tbody').addClass('hidden') else $('tbody').removeClass('hidden')
                Wstm.desk.sorting.calculate(true)
                return
              return
            else if $select.hasClass 'wstm'
              ###
              Handled by Wstm.desk.select
              ###
            else
              $log 'Select not handled!'
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
                  Wstm.desk.sorting.selects($('input.repair'))
              return
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
                $button.on  'click', Wstm.desk.sorting.calculate
                $button.on  'click', Trst.desk.buttons.action.save
            else if Trst.desk.hdo.dialog is 'show'
              if $bd.action is 'print'
                $button.on 'click', ()->
                  Trst.msgShow Trst.i18n.msg.report.start
                  $.fileDownload "/sys/wstm/sorting/print?id=#{Trst.desk.hdo.oid}",
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
              Wstm.desk.sorting.calculate()
              return
            return
          return
        init: ()->
          if $('#date_show').length
            now = new Date()
            min = if Trst.lst.admin is 'true' then new Date(now.getFullYear(),now.getMonth() - 1,1) else new Date(now.getFullYear(),now.getMonth(),1)
            $('#date_show').datepicker 'option', 'maxDate', '+0'
            $('#date_show').datepicker 'option', 'minDate', min
          Wstm.desk.sorting.buttons($('button'))
          Wstm.desk.sorting.selects($('select.wstm'))
          Wstm.desk.sorting.inputs($('input'))
          $log 'Wstm.desk.sorting.init() OK...'
  Wstm.desk.sorting
