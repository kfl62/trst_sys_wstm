define () ->
  $.extend true,Wstm,
    desk:
      cassation:
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
            if Wstm.desk.cassation.validate.stock(stck,qu)
              qu  = stck; res = 0
              $row.find('span[data-val=qu]').text(qu).decFixed(2)
              $row.find('input[data-val=qu]').val(qu).decFixed(2)
            $row.find('span[data-val=ord]').text("#{i}.")
            $row.find('input[data-val=val]').val(qu * parseFloat($row.find('input[data-val=pu]').val())).decFixed(2)
            $row.find('input[data-val=val_invoice]').val(qu * parseFloat($row.find('input[data-val=pu_invoice]').val())).decFixed(2)
            $row.find('[data-val=res]').text(res.toFixed(2))
            tot_qu += qu
            i += 1
            return
          vt.find('[data-val=tot-qu]').text(tot_qu.toFixed(2))
          return
        validate:
          stock: (s,q)->
            if s - q < 0
              alert(Trst.i18n.msg.cassation_negative_stock.replace('%{stck}',s.toFixed(2)).replace('%{res}',(q - s).toFixed(2)))
              return true
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
                return
              return
            if $input.data().mark is 'wpu'
              $input.on 'change', ()->
                Trst.msgShow()
                if $input.is(':checked')
                  $url = "/sys/partial/wstm/cassation/_doc_add_line?wpu=#{$input.val()}"
                  $('td.add-line-container').load $url, ()->
                    Wstm.desk.cassation.buttons($('span.button'))
                    Wstm.desk.cassation.inputs($('input[data-mark=wpu]'))
                    Wstm.desk.cassation.selects($('select[data-val=freight]'))
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
            if $select.data('val') is 'freight'
              $select.on 'change', ()->
                if $select.val() is 'null'
                  Wstm.desk.cassation.lineNewReset()
                else
                  Wstm.desk.cassation.lineNewData()
                  $('input[data-mark~=related-add][data-val=qu]').focus().select()
                return
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
            if $button.hasClass('fa-refresh')
              $button.off 'click'
              $button.on 'click', ()->
                Wstm.desk.cassation.lineNewReset()
                return
            if $button.hasClass('fa-plus-circle')
              $button.off 'click'
              $button.on 'click', ()->
                Wstm.desk.cassation.lineInsert()
                return
            if $button.hasClass('fa-minus-circle')
              $button.off 'click'
              $button.on 'click', ()->
                $button.parentsUntil('tbody').last().remove()
                Wstm.desk.cassation.calculate()
                Wstm.desk.cassation.lineNewReset()
                return
              return
          return
        init: ()->
          @buttons($('button, span.button'))
          @selects($('select'))
          @inputs($('input'))
          @template = $('tr.template')?.remove()
          @lineNewReset()
          $log 'Wstm.desk.cassation.init() OK...'
  Wstm.desk.cassation
