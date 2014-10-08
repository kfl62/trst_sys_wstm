define () ->
  $.extend true,Wstm,
    desk:
      delivery_note:
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
          pu_invoice = v.filter('input[data-val=pu_invoice]').val(); pu_invoice = if $.isNumeric(pu_invoice) then parseFloat(pu_invoice).toFixed(4) else '0.0000'
          $.extend true,
            $fd,
            {ord: ord;freight_id: freight_id;id_date: $('#date_send').val();qu: qu;pu_invoice: pu_invoice}
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
          r  = @lineNewData()
          vl = $('tr[data-mark~=related]').not('.hidden')
          vt = $('tr[data-mark~=related-total]')
          i  = 1; tot_qu = 0
          vl.each ()->
            $row = $(@)
            $row.find('input').each ()->
              $(@).attr('name',$(@).attr('name').replace(/\d/,i))
              return
            stck = parseFloat($row.find('span[data-val=stck]').text())
            qu   = parseFloat($row.find('input[data-val=qu]').val())
            res  = (stck - qu).round(2)
            if Wstm.desk.delivery_note.validate.stock(stck,qu)
              qu  = stck; res = 0
              $row.find('span[data-val=qu]').text(qu).decFixed(2)
              $row.find('input[data-val=qu]').val(qu).decFixed(2)
            $row.find('span[data-val=ord]').text("#{i}.")
            $row.find('input[data-val=val]').val(qu * parseFloat(r.pu)).decFixed(2)
            $row.find('input[data-val=val_invoice]').val(qu * parseFloat(r.pu_invoice)).decFixed(2)
            $row.find('[data-val=res]').text(res.toFixed(2))
            tot_qu += qu
            i += 1
            return
          vt.find('[data-val=tot-qu]').text(tot_qu.toFixed(2))
          return
        validate:
          filter: ()->
            if $('#client_id').val() isnt '' and $('#transporter_id').val() isnt '' and $('#transp_d_id').val() isnt '' and $('#transp_d_id').val() isnt 'new'
              $url = Trst.desk.hdf.attr('action')
              $url += "?client_id=#{$('#client_id').val()}"
              $url += "&transp_id=#{$('#transp_id').val()}"
              $url += "&transp_d_id=#{$('#transp_d_id').val()}"
              $url += "&client_d_id=#{$('#client_d_id').val()}" if $('#client_d_id').val() isnt '' and $('#client_d_id').val() isnt 'new'
              $('button[data-action="create"]').data('url', $url)
              $('button[data-action="create"]').button 'option', 'disabled', false
            else
              $('button[data-action="create"]').button 'option', 'disabled', true
            return
          create: ()->
            if (/[A-Z]{3}-$/).test($('input[name*="doc_name"]').val()) or $('input[name*="doc_name"]').val() is '' or $('input[name*="doc_plat"]').val() is ''
              alert Trst.i18n.msg.delivery_note_not_complete
              return false
            else
              if $('span[data-val=nro]').text() isnt '1.'
                $('button[data-action="save"]').button 'option', 'disabled', false
              return true
          stock: (s,q)->
            if s - q < 0
              alert(Trst.i18n.msg.delivery_note_negative_stock.replace('%{stck}',s.toFixed(2)).replace('%{res}',(q - s).toFixed(2)))
              return true
            return
        inputs: (inpts)->
          inpts.each ()->
            $input = $(@)
            if $input.attr('id') is 'date_show'
              $input.on 'change', ()->
                if Trst.desk.hdo.dialog is 'create'
                  $('input[name*="id_date"]').each ()->
                    $(@).val($('#date_send').val())
                    return
              return
            if $input.data().mark is 'wpu'
              $input.on 'change', ()->
                Trst.msgShow()
                if $input.is(':checked')
                  $url = "/sys/partial/wstm/delivery_note/_doc_add_line?wpu=#{$input.val()}"
                  $('td.add-line-container').load $url, ()->
                    Wstm.desk.delivery_note.buttons($('span.button'))
                    Wstm.desk.delivery_note.inputs($('input[data-mark=wpu]'))
                    Wstm.desk.delivery_note.selects($('select[data-val=freight]'))
                    Trst.desk.inputs.handleUI()
                    Trst.msgHide()
                    return
                return
          return
        selects: (slcts)->
          slcts.each ()->
            $select = $(@)
            $sd = $select.data()
            $id = $select.attr('id')
            if $sd.mark is 's2'
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
                          $dlgadd.data('url','/sys/wstm/partner_firm/person')
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
            if $sd.val is 'freight'
              $select.on 'change', ()->
                if Wstm.desk.delivery_note.validate.create()
                  Wstm.desk.delivery_note.lineNewData()
                  $('input[data-val=qu]').focus().select()
                else
                  $select.val('null')
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
                  $markup += "<span class='repair'>Doc: </span>"
                  $markup += "<span class='truncate-70'>#{d.text.doc_name}</span>"
                  $markup += "<span class='repair'> - Firma: </span>"
                  $markup += "<span class='truncate-200'>#{d.text.client}</span>"
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
            if Trst.desk.hdo.dialog is 'create'
              if $bd.action is 'save'
                $button.button 'option', 'disabled', true
            if $button.hasClass('fa-refresh')
              $button.off 'click'
              $button.on 'click', ()->
                Wstm.desk.delivery_note.lineNewReset()
                return
            if $button.hasClass('fa-plus-circle')
              $button.off 'click'
              $button.on 'click', ()->
                Wstm.desk.delivery_note.lineInsert()
                return
            if $button.hasClass('fa-minus-circle')
              $button.off 'click'
              $button.on 'click', ()->
                $button.parentsUntil('tbody').last().remove()
                Wstm.desk.delivery_note.calculate()
                Wstm.desk.delivery_note.lineNewReset()
                return
              return
          return
        init: ()->
          @buttons($('button,span.button'))
          @selects($('input[data-mark~=s2],input[data-mark~=repair],select'))
          @inputs($('input'))
          @template = $('tr.template')?.remove()
          @lineNewReset()
          $log 'Wstm.desk.delivery_note.init() OK...'
  Wstm.desk.delivery_note
