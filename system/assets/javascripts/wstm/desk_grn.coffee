define () ->
  $.extend true,Wstm,
    desk:
      grn:
        calculate: ()->
          $rows  = $('tr.freight')
          $total = $('tr.total')
          tot_val = 0; tot_p03 = 0;
          $rows.each ()->
            $tr = $(@)
            $sd = $tr.find('select').find('option:selected').data()
            pu  = $tr.find('input[name*="pu"]').decFixed(2)
            qu  = $tr.find('input[name*="qu"]').decFixed(2)
            val = (parseFloat(pu.val()) * parseFloat(qu.val())).round(2)
            p03 = if ($sd.p03 and $('#supplr_id').data('p03')) then (val * 0.03).round(2) else 0
            tot_val += val; tot_p03 += p03
            $tr.find('span.val').text(val.toFixed(2))
            $tr.find('span.p03').text(p03.toFixed(2))
            $tr.find('input[name*="val"]').val(val.toFixed(2))
            return
          $total.find('span.val').text(tot_val.toFixed(2))
          $total.find('span.p03').text(tot_p03.toFixed(2))
          $total.find('input[name*="sum_100"]').val(tot_val.toFixed(2))
          $total.find('input[name*="sum_003"]').val(tot_p03.toFixed(2))
          return
        validate:
          filter: ()->
            if $('#supplr_id').val() isnt '' and $('#transporter_id').val() isnt '' and $('#transp_d_id').val() isnt '' and $('#transp_d_id').val() isnt 'new'
              $url = Trst.desk.hdf.attr('action')
              $url += "?supplr_id=#{$('#supplr_id').val()}"
              $url += "&transp_id=#{$('#transp_id').val()}"
              $url += "&transp_d_id=#{$('#transp_d_id').val()}"
              $url += "&supplr_d_id=#{$('#supplr_d_id').val()}" if $('#supplr_d_id').val() isnt '' and $('#supplr_d_id').val() isnt 'new'
              $('button.dn').data('url', $url)
              $('button.dn').button 'option', 'disabled', false
            else
              $('button.dn').button 'option', 'disabled', true
            return
          create: ()->
            if $('input#transp_d_id').length
              $transp_d = $('input#transp_d_id')
              if $transp_d.select2('val') is '' or $transp_d.select2('val') is 'new'
                $('button[data-action="save"]').button 'option', 'disabled', true
              else
                $('button[data-action="save"]').button 'option', 'disabled', false
            if $('select.doc_type').length
              if $('select.doc_type').val() isnt 'null' and $('input[name*="doc_name"]').val() isnt '' and $('input[name*="doc_plat"]').val() isnt ''
                $('button[data-action="save"]').button 'option', 'disabled', false
                return true
            return
        selectedDeliveryNotes: ()->
          @dln_ary = []
          $('input:checked').each ()->
            Wstm.desk.grn.dln_ary.push(@id)
            return
          $url = Trst.desk.hdf.attr('action')
          $url += "&p03=#{$('select.p03').val()}"
          $url += "&dln_ary=#{Wstm.desk.grn.dln_ary}" if Wstm.desk.grn.dln_ary.length
          Trst.desk.init($url)
          return
        inputs: (inpts)->
          inpts.each ()->
            $input = $(@)
            $id = $input.attr('id')
            if $input.hasClass 'dln_ary'
              $input.on 'change', ()->
                Wstm.desk.grn.selectedDeliveryNotes()
                return
            if $input.attr('id') is 'date_show' and $('input[name*="doc_date"]').length
              $input.on 'change', ()->
                $('input[name*="doc_date"]').val($('#date_send').val())
                $('input[name*="id_date"]').each ()->
                  $(@).val($('#date_send').val()) unless $(@).val() is ''
                  return
                $('select.doc_type').focus()
                return
            return
          return
        selects: (slcts)->
          slcts.each ()->
            $select = $(@)
            $sd = $select.data()
            $id = $select.attr('id')
            if $select.hasClass 'wstm'
              if $select.hasClass 'p03'
                $select.on 'change', ()->
                  $url  = Trst.desk.hdf.attr('action')
                  $url += "&p03=#{$select.val()}" unless $select.val() is 'null'
                  Trst.desk.init($url)
                  return
              if $select.hasClass 'doc_type'
                $select.on 'change', ()->
                  $('input[name*="doc_date"]').val($('#date_send').val())
                  $select.next().focus()
                  return
              if $select.hasClass 'freight'
                $select.on 'change', ()->
                  if Wstm.desk.grn.validate.create()
                    $sod = $select.find('option:selected').data()
                    $inp = $select.parentsUntil('tbody').last().find('input')
                    $inp.filter('[name*="freight_id"]').val($select.val())
                    $inp.filter('[name*="id_date"]').val($('#date_send').val())
                    $inp.filter('[name*="id_stats"]').val($sod.id_stats)
                    $inp.filter('[name*="um"]').val($sod.um)
                    pu = $inp.filter('[name*="pu"]').val($sod.pu).decFixed(2)
                    qu = $inp.filter('[name*="qu"]').val('0.00')
                    pu.on 'change', ()->
                      Wstm.desk.grn.calculate()
                    qu.on 'change', ()->
                      Wstm.desk.grn.calculate()
                    Wstm.desk.grn.calculate()
                    qu.focus().select()
                  else
                    alert Trst.i18n.msg.grn_not_complete
                    $select.val('null')
                    $('button[data-action="save"]').button 'option', 'disabled', true
                  return
            else if $select.hasClass 'select2'
              if $id in ['supplr_id','transp_id']
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
                      Wstm.desk.grn.validate.filter()
                  else
                    $select.next().select2('data',null)
                    $select.next().select2('destroy')
                    $select.next().next().hide()
                  Wstm.desk.grn.validate.filter()
              if $id is 'transp_d_id' and Trst.desk.hdo.dialog is 'create'
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
                      id: $sd.transp_id
                    results: (data)->
                      results: data
                $select.on 'change', ()->
                  if $select.select2('data')
                    if $select.select2('data').id is 'new'
                      $dlgadd = $select.nextAll('button')
                      $dlgadd.data('url','/sys/wstm/partner_firm_person')
                      $dlgadd.data('r_id',$sd.transp_id)
                      $dlgadd.data('r_mdl','firm')
                      $dlgadd.show()
                    else
                      $select.nextAll('button').hide()
                      $select.next().addClass('ce st').focus()
                  else
                    $select.nextAll('button').hide()
                  Wstm.desk.grn.validate.create()
                  return
            else
              $log 'Select not handled!'
            return
          return
        buttons: (btns)->
          btns.each ()->
            $button = $(@)
            $bd = $button.data()
            $id = $button.attr('id')
            if Trst.desk.hdo.dialog is 'filter'
              if $id in ['supplr_d','transp_d']
                $button.hide()
              if $bd.action is 'create'
                if $('input:checked').length is 0
                  $button.button 'option', 'disabled', true
                else
                  $bd   = $button.data()
                  $url  = '/sys/wstm/grn/create?id_intern=true'
                  $url += "&unit_id=#{Trst.desk.hdo.unit_id}"
                  $url += "&dln_ary=#{Wstm.desk.grn.dln_ary}"
                  $bd.url = $url
                  $button.button 'option', 'disabled', false
            else if Trst.desk.hdo.dialog is 'create'
              if $id is 'transp_d'
                $button.hide()
              if $bd.action is 'save'
                $button.button 'option', 'disabled', true
                $button.data('remove',false)
            else if Trst.desk.hdo.dialog is 'show'
              if $bd.action is 'print'
                $button.on 'click', ()->
                  Trst.msgShow Trst.i18n.msg.report.start
                  $.fileDownload "/sys/wstm/grn/print?id=#{Trst.desk.hdo.oid}",
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
              Wstm.desk.grn.calculate()
              return
          return
        init: ()->
          if $('#date_show').length
            now = new Date()
            min = if Trst.lst.admin is 'true' then new Date(now.getFullYear(),now.getMonth() - 1,1) else min = new Date(now.getFullYear(),now.getMonth(),1)
            $('#date_show').datepicker 'option', 'maxDate', '+0'
            $('#date_show').datepicker 'option', 'minDate', min
          Wstm.desk.grn.buttons($('button'))
          Wstm.desk.grn.selects($('select.wstm, input.select2'))
          Wstm.desk.grn.inputs($('input'))
          $log 'Wstm.desk.grn.init() OK...'
  Wstm.desk.grn
