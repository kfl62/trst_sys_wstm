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
          $('select[data-mark~=related-add]').val('null').focus()
          return
        lineNewData: ()->
          v = $('[data-mark~=related-add]')
          $freight = v.filter('[data-val=freight]')
          $fd = $freight.find('option:selected').data()
          ord = $('tr[data-mark~=related]').not('.hidden').length + 1
          name       = $freight.find('option:selected').text().split('-')[0]
          freight_id = $freight.val()
          id_date    = $('input[id=date_send]').val()
          id_stats   = $fd.id_stats
          um         = $fd.um; v.filter('[data-val=um]').val(um)
          pu         = $fd.pu;   pu = parseFloat(pu).toFixed(2);     v.filter('[data-val=pu]').val(pu)
          stck       = $fd.stck; stck = parseFloat(stck).toFixed(2); v.filter('[data-val=stck]').val(stck)
          qu         = v.filter('[data-val=qu]').val(); if qu is '' then qu = 0.toFixed(2) else qu = parseFloat(qu).toFixed(2)
          result:
            ord: ord; name: name;freight_id: freight_id; id_date: id_date; id_stats: id_stats; um: um; pu: pu; stck: stck; qu: qu
        lineInsert: ()->
          r = @lineNewData().result
          l = @template.clone().removeClass('template')
          l.find('span,input').each ->
            e = $(@)
            if e.data('val')
              e.text r[e.data('val')]  if e.is('span')
              e.val r[e.data('val')]  if e.is('input')
          $('tr[data-mark~=related-total]').before l
          @calculate()
          @lineNewReset()
          @buttons($('span.button'))
          return
        calculate: ()->
          r  = @lineNewData().result
          vl = $('tr[data-mark~=related]').not('.hidden')
          vt = $('tr[data-mark~=related-total]')
          i = 1; tot_qu = 0
          vl.each ()->
            $row = $(@)
            $row.find('input').each ()->
              $(@).attr('name',$(@).attr('name').replace(/\d/,i))
              return
            stck = parseFloat($row.find('span[data-val=stck]').text())
            qu   = parseFloat($row.find('input[data-val=qu]').val())
            res  = (stck - qu).round(2)
            if res < 0
              alert(Trst.i18n.msg.cassation_negative_stock
                .replace '%{stck}', stck.toFixed(2)
                .replace '%{res}',  (0 - res).toFixed(2))
              qu  = stck; res = 0
              $row.find('span[data-val=qu]').text(qu).decFixed(2)
              $row.find('input[data-val=qu]').val(qu).decFixed(2)
            tot_qu += qu
            $row.find('[data-val=res]').text(res.toFixed(2))
            i += 1
            return
          vt.find('[data-val=tot-qu]').text(tot_qu.toFixed(2))
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
