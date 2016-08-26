define () ->
  $.extend true,Wstm,
    desk:
      expenditure:
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
          _03 = if $fd.p03 then (parseFloat(val) * 0.03).toFixed(2) else '0.00'
          _16 = (parseFloat(val) * 0.0).toFixed(2)
          out = (parseFloat(val) - parseFloat(_03) - parseFloat(_16)).toFixed(2)
          $.extend true,
            $fd,
            {ord: ord;freight_id: freight_id;id_date: $('#date_send').val();qu: qu;pu: pu;val: val;_03: _03;_16: _16;out: out}
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
        calculate: ()->
          vl = $('tr[data-mark~=related]').not('.hidden')
          vt = $('tr[data-mark~=related-total]')
          i  = 1; sum_100 = 0; sum_003 = 0; sum_016 = 0; sum_out = 0
          vl.each ()->
            $row = $(@)
            $row.find('span[data-val=ord]').text("#{i}.")
            $row.find('input').each ()->
              $(@).attr('name',$(@).attr('name').replace(/\d/,i))
              return
            val = parseFloat($row.find('span[data-val=val]').text())
            _03 = parseFloat($row.find('span[data-val=_03]').text())
            _16 = parseFloat($row.find('span[data-val=_16]').text())
            out = parseFloat($row.find('span[data-val=out]').text())
            sum_100 += val; sum_003 += _03; sum_016 += _16; sum_out += out
            i += 1
            return
          vt.find('span[data-val=sum-100]').text(sum_100.toFixed(2))
          vt.find('span[data-val=sum-003]').text(sum_003.toFixed(2))
          vt.find('span[data-val=sum-016]').text(sum_016.toFixed(2))
          vt.find('span[data-val=sum-out]').text(sum_out.toFixed(2))
          vt.find('input[data-val=sum-100]').val(sum_100.toFixed(2))
          vt.find('input[data-val=sum-003]').val(sum_003.toFixed(2))
          vt.find('input[data-val=sum-016]').val(sum_016.toFixed(2))
          vt.find('input[data-val=sum-out]').val(sum_out.toFixed(2))
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
                  Wstm.desk.expenditure.selects($('input.repair'))
              return
            else if $input.hasClass('pu') or $input.hasClass('qu')
              $input.on 'change', ()->
                Wstm.desk.expenditure.calculate()
              return
          return
        noMatchesMsg: (term)->
          $button = $('button#client')
          if term.length < 13
            $button.button 'option', 'disabled', true
            $msg = Trst.i18n.msg.id_pn.start.replace '%{data}', 13 - term.length
          else if term.length is 13
            if Trst.desk.inputs.__f.validateIdPN(term)
              $button.button 'option', 'disabled', false
              $button.data 'url', "/sys/wstm/partner_person?id_pn=#{term}"
              $msg = Trst.i18n.msg.id_pn.valid
            else
              $button.button 'option', 'disabled', true
              $msg = Trst.i18n.msg.id_pn.invalid
          else
            $button.button 'option', 'disabled', true
            $msg = Trst.i18n.msg.id_pn.too_long
        selects: (slcts)->
          slcts.each ()->
            $select = $(@)
            $sd = $select.data()
            if $sd.mark is 's2'
              $ph = Trst.i18n.select[Trst.desk.hdo.js_ext][$sd.ph]
              $select.select2
                placeholder: $ph
                minimumInputLength: $sd.minlength
                formatNoMatches: (term)->
                  Wstm.desk.expenditure.noMatchesMsg(term)
                ajax:
                  url: "/utils/search/#{$sd.search}"
                  dataType: 'json'
                  quietMillis: 1000
                  data: (term)->
                    q: term
                  results: (data)->
                    results: data
              $select.unbind()
              $select.on 'change', ()->
                $button = $('button[data-action=create]:not(#client)')
                $button.data 'url', "/sys/wstm/expenditure?client_id=#{$select.select2('val')}"
                $button.button 'option', 'disabled', false
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
                  $markup += "<span>#{d.text.name} </span>"
                  $markup += "<span>- #{d.text.time} - </span>"
                  $markup += "<span>Val:</span>"
                  $markup += "<span style='width:50px;text-align:right;display:inline-block'>#{d.text.val}</span>"
                  $markup += "<span> - Cash:</span>"
                  $markup += "<span style='width:50px;text-align:right;display:inline-block'>#{d.text.out}</span>"
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
                if Wstm.desk.expenditure.validate.create()
                  Wstm.desk.expenditure.lineNewData()
                  $('input[data-mark~=related-add][data-val=qu]').focus().select()
                else
                  $select.val('null')
                return
          return
        buttons: (btns)->
          btns.each ()->
            $button = $(@)
            $bd = $button.data()
            if Trst.desk.hdo.dialog is 'filter'
              if $bd.action is 'create'
                $button.button 'option', 'disabled', true
            if Trst.desk.hdo.dialog is 'create'
              if $bd.action is 'save'
                if Trst.desk.hdf.attr('action') is '/sys/wstm/expenditure'
                  $button.data('remove',false)
                  $button.off 'click', Trst.desk.buttons.action.save
                  $button.on  'click', Wstm.desk.expenditure.calculate
                  $button.on  'click', Trst.desk.buttons.action.save
                  $log 'Wstm::Expenditure save...'
            if $button.hasClass('fa-refresh')
              $button.off 'click'
              $button.on 'click', ()->
                Wstm.desk.expenditure.lineNewReset()
                return
            if $button.hasClass('fa-plus-circle')
              $button.off 'click'
              $button.on 'click', ()->
                Wstm.desk.expenditure.lineInsert()
                return
            if $button.hasClass('fa-minus-circle')
              $button.off 'click'
              $button.on 'click', ()->
                $button.parentsUntil('tbody').last().remove()
                Wstm.desk.expenditure.calculate()
                Wstm.desk.expenditure.lineNewReset()
                return
              return
          return
        init: ()->
          @buttons($('button,span.button'))
          @selects($('select, input[data-mark~=s2], input[data-mark~=repair]'))
          @inputs($('input'))
          @template = $('tr.template')?.remove()
          @lineNewReset()
          $log 'Wstm.desk.expenditure.init() OK...'
  Wstm.desk.expenditure
