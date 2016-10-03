define () ->
  $.extend true,Wstm,
    desk:
      grn:
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
          pu = v.filter('input[data-val=pu]').val(); pu = if $.isNumeric(pu) then parseFloat(pu).toFixed(4) else parseFloat($fd.pu).toFixed(4)
          v.filter('input[data-val=pu]').val(pu)
          qu  = v.filter('input[data-val=qu]').val(); qu = if $.isNumeric(qu) then parseFloat(qu).toFixed(2) else '0.00'
          val = (parseFloat(qu) * parseFloat(pu)).toFixed(2)
          _03 = if ($fd.p03 and $('#supplr_id').data('p03')) then (parseFloat(val) * 0.03).toFixed(2) else '0.00'
          out = (parseFloat(val) - parseFloat(_03)).toFixed(2)
          $.extend true,
            $fd,
            {ord: ord;freight_id: freight_id;id_date: $('#date_send').val();qu: qu;pu: pu;val: val;_03: _03;out: out}
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
        calculate: ()->
          vl = $('tr[data-mark~=related]').not('.hidden')
          vt = $('tr[data-mark~=related-total]')
          i  = 1; sum_100 = 0; sum_003 = 0; sum_out = 0
          vl.each ()->
            $row = $(@)
            $row.find('span[data-val=ord]').text("#{i}.")
            $row.find('input').each ()->
              $(@).attr('name',$(@).attr('name').replace(/\d/,i))
              return
            val = parseFloat($row.find('span[data-val=val]').text())
            _03 = parseFloat($row.find('span[data-val=_03]').text())
            out = parseFloat($row.find('span[data-val=out]').text())
            sum_100 += val; sum_003 += _03; sum_out += out
            i += 1
            return
          vt.find('span[data-val=sum-100]').text(sum_100.toFixed(2))
          vt.find('span[data-val=sum-003]').text(sum_003.toFixed(2))
          vt.find('span[data-val=sum-out]').text(sum_out.toFixed(2))
          vt.find('input[data-val=sum-100]').val(sum_100.toFixed(2))
          vt.find('input[data-val=sum-003]').val(sum_003.toFixed(2))
          vt.find('input[data-val=sum-out]').val(sum_out.toFixed(2))
          return
        validate:
          filter: ()->
            if $('#supplr_id').val() isnt '' and $('#transporter_id').val() isnt '' and $('#transp_d_id').val() isnt '' and $('#transp_d_id').val() isnt 'new'
              $url = Trst.desk.hdf.attr('action')
              $url += "?supplr_id=#{$('#supplr_id').val()}"
              $url += "&transp_id=#{$('#transp_id').val()}"
              $url += "&transp_d_id=#{$('#transp_d_id').val()}"
              $url += "&supplr_d_id=#{$('#supplr_d_id').val()}" if $('#supplr_d_id').val() isnt '' and $('#supplr_d_id').val() isnt 'new'
              $('button[data-action="create"]').last().data('url', $url)
              $('button[data-action="create"]').last().button 'option', 'disabled', false
            else
              $('button[data-action="create"]').last().button 'option', 'disabled', true
            return
          create: ()->
            $('input[data-mark~=related-add][data-val=pu]').val($('select[data-mark~=related-add][data-val=freight] option:selected').data('pu'))
            $('input[data-mark~=related-add][data-val=qu]').val('0.00')
            if $('span[data-val=nro]').text() isnt '1.'
              $('button[data-action="save"]').button 'option', 'disabled', false
            true
            if $('input#transp_d_id').length
              $transp_d = $('input#transp_d_id')
              if $transp_d.select2('val') is '' or $transp_d.select2('val') is 'new'
                $('button[data-action="save"]').button 'option', 'disabled', true
              else
                $('button[data-action="save"]').button 'option', 'disabled', false
            if $('select.doc_type').length
              if $('select.doc_type').val() isnt 'null' and $('input[name*="doc_name"]').val() isnt '' and $('input[name*="doc_plat"]').val() isnt ''
                $('button[data-action="save"]').button 'option', 'disabled', false
                $('span.fa-plus-circle').show()
                return true
            return
        selectedDeliveryNotes: ()->
          @dln_ary = []
          $('input:checked').each ()->
            Wstm.desk.grn.dln_ary.push(@id)
            return
          $url = Trst.desk.hdf.attr('action')
          $url += "&p03=#{$('select').val()}"
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
            if $input.attr('id') is 'date_show'
              $input.on 'change', ()->
                if Trst.desk.hdo.dialog is 'create'
                  $('input[name*="doc_date"]').val($('#date_send').val())
                  $('input[name*="id_date"]').each ()->
                    $(@).val($('#date_send').val()) unless $(@).val() is ''
                    return
                  $('select.doc_type').focus()
                if Trst.desk.hdo.dialog is 'repair'
                  Wstm.desk.grn.selects($('input.repair'))
              return
            if $input.data().val is 'qu'
              $input.keypress (e)->
                key = e.which
                if key is 13
                  $('span.button.fa-plus-circle').click()
                  return false
                return
              return
            return
          return
        selects: (slcts)->
          slcts.each ()->
            $select = $(@)
            $sd = $select.data()
            $id = $select.attr('id')
            if $sd.mark is 'p03'
              $select.on 'change', ()->
                $url  = Trst.desk.hdf.attr('action')
                $url += "&p03=#{$select.val()}" unless $select.val() is 'null'
                Trst.desk.init($url)
                return
            if $select.data().mark is 's2'
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
                          $dlgadd.data('url','/sys/wstm/partner_firm/person')
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
                      $dlgadd.data('url','/sys/wstm/partner_firm/person')
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
            if $sd.mark is 'repair'
              $ph = Trst.i18n.select[Trst.desk.hdo.js_ext][$sd.ph]
              $select.select2
                placeholder: $ph
                allowClear: true
                quietMillis: 1000
                ajax:
                  url: "/utils/search/#{$sd.search}"
                  dataType: 'json'
                  data: (term)->
                    uid: $sd.uid
                    day: $('#date_send').val()
                    q:   term
                  results: (data)->
                    results: data
                formatResult: (d)->
                  $markup  = "<div title='#{d.text.title}'>"
                  $markup += "<span class='dsp-ib'>Doc: </span>"
                  $markup += "<span class='w-8rem dsp-ib'>#{d.text.doc_name}</span>"
                  $markup += "<span class='dsp-ib'> - Firma: </span>"
                  $markup += "<span class='w-20rem dsp-ib'>#{d.text.supplier}</span>"
                  $markup += "</div>"
                  $markup
                formatSelection: (d)->
                  d.text.name
                formatSearching: ()->
                  Trst.i18n.msg.searching
                formatNoMatches: (t)->
                  Trst.i18n.msg.no_matches
              $select.off()
              $select.on 'change', ()->
                if $select.select2('val') isnt ''
                  $url  = Trst.desk.hdf.attr('action')
                  $url += "/#{$select.select2('val')}"
                  Trst.desk.closeDesk(false)
                  Trst.desk.init($url)
                return
            if $sd.val is 'freight'
              $select.on 'change', ()->
                if Wstm.desk.grn.validate.create()
                  Wstm.desk.grn.lineNewData()
                  $('input[data-mark~=related-add][data-val=qu]').focus().select()
                else
                  $select.val('null')
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
                  $button.button 'option', 'disabled', true if $id is undefined
                else
                  $bd   = $button.data()
                  $url  = '/sys/wstm/grn/create?id_intern=true'
                  $url += "&unit_id=#{Trst.desk.hdo.unit_id}"
                  $url += "&dln_ary=#{Wstm.desk.grn.dln_ary}"
                  $bd.url = $url
                  $button.button 'option', 'disabled', false
            if Trst.desk.hdo.dialog is 'show'
              if $bd.action is 'print'
                $button.on 'click', ()->
                  Trst.msgShow Trst.i18n.msg.report.start
                  $.fileDownload "/sys/wstm/grn/print?id=#{Trst.desk.hdo.oid}",
                    successCallback: ()->
                      Trst.msgHide()
                    failCallback: ()->
                      Trst.msgHide()
                      Trst.desk.downloadError Trst.desk.hdo.model_name
                  return
                return
            if $button.hasClass('fa-refresh')
              $button.off 'click'
              $button.on 'click', ()->
                Wstm.desk.grn.lineNewReset()
                return
            if $button.hasClass('fa-plus-circle')
              $button.off 'click'
              $button.on 'click', ()->
                Wstm.desk.grn.lineInsert()
                return
            if $button.hasClass('fa-minus-circle')
              $button.off 'click'
              $button.on 'click', ()->
                $button.parentsUntil('tbody').last().remove()
                Wstm.desk.grn.calculate()
                Wstm.desk.grn.lineNewReset()
                return
              return
          return
        init: ()->
          @buttons($('button,span.button'))
          @selects($('input[data-mark~=s2],input[data-mark~=repair],select'))
          @inputs($('input'))
          @template = $('tr.template')?.remove()
          @lineNewReset()
          $log 'Wstm.desk.grn.init() OK...'
  Wstm.desk.grn
