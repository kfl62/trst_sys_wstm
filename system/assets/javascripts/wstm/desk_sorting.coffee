define () ->
  $.extend true,Wstm,
    desk:
      sorting:
        lineNewReset: ()->
          next = $('tr[data-mark~=related]').not('.hidden').length + 1
          if next is 1
            $('tr[data-mark~=related-header], tr[data-mark~=related-total]').addClass 'hidden'
            $('button[data-action=save]').button 'option', 'disabled', true
          else
            $('tr[data-mark~=related-header], tr[data-mark~=related-total]').removeClass 'hidden'
            $('button[data-action=save]').button 'option', 'disabled', false
          $('span[data-val=nro').text("#{next}.")
          $('input[data-mark~=related-add]').val ''
          $('select[data-mark~=related-add]').val('null')
          return
        lineNewData: ()->
          v = $('[data-mark~=related-add]')
          $freight = v.filter('[data-val=freight]'); $fd = $freight.find('option:selected').data()
          ord = $('tr[data-mark~=related]').not('.hidden').length + 1
          freight_id = $freight.val()
          um = $fd.um; v.filter('[data-val=um]').val(um)
          stck = $fd.stck; stck = (if $.isNumeric(stck) then parseFloat(stck).toFixed(2) else '0.00'); v.filter('[data-val=stck]').val(stck)
          qu = v.filter('input[data-val=qu]').val(); qu = if $.isNumeric(qu) then parseFloat(qu).toFixed(2) else '0.00'
          pu = v.filter('input[data-val=pu]').val(); pu = if $.isNumeric(pu) then parseFloat(pu).toFixed(4) else '0.0000'
          $.extend true,
            $fd,
            {ord: ord;freight_id: freight_id;id_date: $('#date_send').val();qu: qu}
        lineInsert: ()->
          r = @lineNewData()
          l = @template.clone().removeClass('template')
          l.find('span,input').each ->
            e = $(@)
            if e.data('val')
              e.text r[e.data('val')]  if e.is('span')
              e.val  r[e.data('val')]  if (e.is('input') and e.val() is '')
          $('tr[data-mark~=related-total]').before l if parseFloat(r.qu) > 0
          @calculate()
          @lineNewReset()
          @buttons($('span.button'))
          return
        validate:
          create: ()->
            $('input[data-mark~=related-add][data-val=pu]').val($('select[data-mark~=related-add][data-val=freight] option:selected').data('pu'))
            $('input[data-mark~=related-add][data-val=qu]').val('0.00')
            if $('span[data-val=nro]').text() isnt '1.'
              $('button[data-action="save"]').button 'option', 'disabled', false
            true
        calculate: (fromFreight = false)->
          if fromFreight is true
            @rest = $('span[data-val="from-freight-stock"]').text()
          vl = $('tr[data-mark~=related]').not('.hidden')
          vt = $('tr[data-mark~=related-total]')
          i  = 1; qu = 0; tot_qu = 0
          vl.each ()->
            $row = $(@)
            $row.find('span[data-val=ord]').text("#{i}.")
            $row.find('input').each ()->
              $(@).attr('name',$(@).attr('name').replace(/\d/,i))
              return
            qu = parseFloat($row.find('input[data-val=qu]').val())
            tot_qu += qu
            i += 1
            return
          vt.find('[data-val=tot-qu]').text(tot_qu.toFixed(2))
          $('span[data-val="from-freight-qu"]').text(tot_qu.toFixed(2))
          $('span[data-val="from-freight-stock"]').text(@rest - tot_qu)
          return
        selects: (slcts)->
          slcts.each ()->
            $select = $(@)
            $sd = $select.data()
            if $sd.mark is 'from-freight'
              $select.on 'change', ()->
                $sod = $select.find('option:selected').data()
                $inp = $select.prevAll('input')
                $inp.filter('[name*="freight_id"]').val($select.val())
                $inp.filter('[name*="id_date"]').val($('#date_send').val())
                $inp.filter('[name*="id_stats"]').val($sod.id_stats)
                $inp.filter('[name*="um"]').val($sod.um)
                $inp.filter('[name*="qu"]').val('0.00')
                $inp.filter('[name*="pu"]').val(parseFloat($sod.pu).toFixed(2))
                $('span[data-val="from-freight-stock"]').text(parseFloat($sod.stck).toFixed(2))
                if $select.val() is 'null' then $('.add-line-container').addClass('hidden') else $('.add-line-container').removeClass('hidden')
                Wstm.desk.sorting.calculate(true)
                return
              return
            if $sd.val is 'freight'
              $select.on 'change', ()->
                if Wstm.desk.sorting.validate.create()
                  Wstm.desk.sorting.lineNewData()
                  $('input[data-mark~=related-add][data-val=qu]').focus().select()
                else
                  $select.val('null')
                return
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
            if Trst.desk.hdo.dialog is 'filter'
              if $bd.action in ['create','show','edit','delete']
                $bd.r_path = 'sys/wstm/cassation/filter'
                return
            if Trst.desk.hdo.dialog is 'create'
              if $button.hasClass('fa-refresh')
                $button.off 'click'
                $button.on 'click', ()->
                  Wstm.desk.sorting.lineNewReset()
                  return
              if $button.hasClass('fa-plus-circle')
                $button.off 'click'
                $button.on 'click', ()->
                  Wstm.desk.sorting.lineInsert()
                  return
              if $button.hasClass('fa-minus-circle')
                $button.off 'click'
                $button.on 'click', ()->
                  $button.parentsUntil('tbody').last().remove()
                  Wstm.desk.sorting.calculate()
                  Wstm.desk.sorting.lineNewReset()
                  return
                return
              return
            if Trst.desk.hdo.dialog is 'show'
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
          return
        init: ()->
          @buttons($('button,span.button'))
          @selects($('select.wstm,select'))
          @inputs($('input'))
          @template = $('tr.template')?.remove()
          @lineNewReset()
          $log 'Wstm.desk.sorting.init() OK...'
  Wstm.desk.sorting
