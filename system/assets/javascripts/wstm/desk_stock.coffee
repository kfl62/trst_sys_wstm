define () ->
  $.extend true,Wstm,
    desk:
      stock:
        template: ()->
          $tr = $('tr.plus')
          $sl = $tr.find(':selected')
          $sd = $sl.data()
          $pu = $tr.find('input.pu')
          $qu = $tr.find('input.quw')
          $vl = $tr.find('span.stats')
          $node = $('tr.freight').last().clone()
          if $node.hasClass 'hidden'
            $('tr.freight').last().remove() unless $('tr.freight').last().find('input[name*="_destroy"]').length
            $node.removeClass 'hidden'
          if Trst.desk.hdo.dialog in ['create','edit']
            $node.find('span.stats').each (i)->
              $(@).html($sl.text()) if i is 0
              $(@).html($sd.um)     if i is 1
              $(@).html($vl.html()) if i is 2
            $node.find('input').each (i)->
              $(@).val($sl.val()).prop('name',(i,o) -> o.replace(/\d/,$('tr.freight').length))    if i is 0
              $(@).val($sd.id_stats).prop('name',(i,o) -> o.replace(/\d/,$('tr.freight').length)) if i is 1
              $(@).val('false').prop('name',(i,o) -> o.replace(/\d/,$('tr.freight').length))      if i is 2
              $(@).val($('input[name*="id_date"]').val()).prop('name',(i,o) -> o.replace(/\d/,$('tr.freight').length)) if i is 3
              $(@).val($sd.um).prop('name',(i,o) -> o.replace(/\d/,$('tr.freight').length))       if i is 4
              $(@).val($pu.val()).prop('name',(i,o) -> o.replace(/\d/,$('tr.freight').length))    if i is 5
              $(@).val($qu.val()).prop('name',(i,o) -> o.replace(/\d/,$('tr.freight').length))    if i is 6
              $(@).val($vl.text()).prop('name',(i,o) -> o.replace(/\d/,$('tr.freight').length))   if i is 7
              $(@).remove() if i > 7
          $tr.find('select').val('null').change()
          $node
        calculate: ()->
          $('tr.freight').each ()->
            $tr= $(@)
            pu = parseFloat($tr.find('input[name*="pu"]').decFixed(2).val())
            qu = parseFloat($tr.find('input[name*="qu"]').decFixed(2).val())
            val= (pu * qu).round(2)
            $tr.find('span.stats').last().html(val.toFixed(2))
            $tr.find('input[name*="val"]').val(val.toFixed(2))
            return
          return
        inputs: (inpts)->
          inpts.each ()->
            $input = $(@)
            if $input.attr('name')?.match(/([^\[^\]]+)/g).pop() in ['pu','quw']
              $input.on 'change', ()->
                Wstm.desk.stock.calculate()
            return
          return
        selects: (slcts)->
          slcts.each ()->
            $select = $(@)
            $tr = $('tr.plus')
            $select.on 'change', ()->
              $sd = $select.find('option:selected').data()
              $tr.find('input.pu').attr('value',$sd.pu).decFixed(2)
              $tr.find('input.quw').attr('value','0.00')
              $tr.find('span.stats').html('0.00')
              return
            return
          return
        buttons: (btns)->
          btns.each ()->
            $button = $(@)
            $bd = $button.data()
            if Trst.desk.hdo.dialog in ['create','edit']
              if $bd.action is 'save'
                  $button.data('remove',false)
                  $button.off 'click', Trst.desk.buttons.action.save
                  $button.on  'click', Wstm.desk.stock.calculate
                  $button.on  'click', Trst.desk.buttons.action.save
                  $log 'Wstm::Stock save...'
          $('span.icon-remove-sign').each ()->
            $button = $(@)
            $button.unbind()
            $tr = $button.parentsUntil('tbody').last()
            if Trst.desk.hdo.dialog is 'create'
              $button.on 'click', ()->
                $tr.remove()
                return
            if Trst.desk.hdo.dialog is 'edit'
              $button.on 'click', ()->
                $destroy = $tr.find('input').last().clone()
                $destroy.attr('name', $destroy.attr('name').replace('id','_destroy'))
                $destroy.val(1)
                $tr.find('input').last().after($destroy)
                $tr.addClass 'hidden'
                return
            return
          $('span.icon-plus-sign').each ()->
            $button = $(@)
            $button.unbind()
            $tr = $button.parentsUntil('tbody').last()
            $tr.css('background-color','lightYellow')
            $button.on 'click', ()->
              if $tr.find('select').val() isnt 'null'
                $tr.before(Wstm.desk.stock.template())
                Wstm.desk.stock.calculate()
                Wstm.desk.stock.buttons($('button'))
              return
            return
          return
        init: ()->
          Wstm.desk.stock.buttons($('button'))
          Wstm.desk.stock.selects($('select.wstm'))
          Wstm.desk.stock.inputs($('input'))
          $log 'Wstm.desk.stock.init() OK...'
  Wstm.desk.stock
