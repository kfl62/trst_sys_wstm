define () ->
  $.extend true,Wstm,
    desk:
      cache_book:
        linesNewReset: ()->
          next = $('tr[data-mark~=related]').not('.hidden').length + 1
          if next is 1
            $('tr[data-mark~=related-header], tr[data-mark~=related-total]').addClass 'hidden'
            $('button[data-action=save]').button 'option', 'disabled', true
          else
            $('tr[data-mark~=related-header], tr[data-mark~=related-total]').removeClass 'hidden'
            $('button[data-action=save]').button 'option', 'disabled', false
          $('span[data-val=nr').text next - 1
          $('span[data-mark~=related-add]').text next + '.'
          $('input[data-mark~=related-add]').val ''
          $('input[data-mark~=related-add][data-val=doc]').focus()
          return
        linesNewData: ()->
          v = $('[data-mark~=related-add]')
          ord = $('tr[data-mark~=related]').not('.hidden').length + 1
          doc = v.filter('[data-val=doc]').val()
          exp = v.filter('[data-val=exp]').val()
          ins = v.filter('[data-val=ins]').val(); if ins is '' then ins = 0 else ins = parseFloat(ins)
          out = v.filter('[data-val=out]').val(); if out is '' then out = 0 else out = parseFloat(out)
          result:
            ord: ord; doc: doc; exp: exp; ins: ins.toFixed(2); out: out.toFixed(2)
        linesInsert: ()->
          r = Wstm.desk.cache_book.linesNewData().result
          l = Wstm.desk.cache_book.template.clone().removeClass('template')
          l.find('span,input').each ->
            e = $(@)
            if e.data('val')
              e.text r[e.data('val')]  if e.is('span')
              e.val r[e.data('val')]  if e.is('input')
          $('tr[data-mark~=related-total]').before l
          Wstm.desk.cache_book.calculate()
          Wstm.desk.cache_book.linesNewReset()
          Wstm.desk.cache_book.buttons($('span.button'))
          return
        calculate: ()->
          r  = Wstm.desk.cache_book.linesNewData().result
          vl = $('tr[data-mark~=related]').not('.hidden')
          vt = $('tr[data-mark~=related-total]')
          ib = parseFloat($('input[data-val=ib]').val())
          i  = 1; vtins = 0; vtout = 0;
          vl.each ()->
            $row = $(@)
            $row.find('input').each ()->
              $input = $(@)
              $input.attr('name', $input.attr('name').replace(/\d/,i) )
              $input.val i  if $input.data('val') is 'ord'
              vtins += parseFloat($input.val())  if $input.data('val') is 'ins'
              vtout += parseFloat($input.val())  if $input.data('val') is 'out'
            $row.find('span[data-val=ord]').text i + '.'
            i += 1
          vt.find('span[data-val=tot-ins]').text vtins.toFixed(2)
          vt.find('span[data-val=tot-out]').text vtout.toFixed(2)
          $fb = ib + vtins - vtout
          $('input[data-val=fb]').val($fb)
          $('span[data-val=fb]').text($fb.toFixed(2))
          if r.ord > 25 and $('#scroll-container').length is 0 then Trst.desk.tables.handleScroll('table[data-mark~=scroll]')
          if r.ord < 26 and $('#scroll-container').length is 1 then Trst.desk.tables.handleScroll('table[data-mark~=scroll]', 0)
          return
        inputs: (inpts)->
          inpts.each ()->
            $input = $(@)
            $ind = $input.data()
            if $input.data('mark') is 'line-add'
              $input.on 'keyup', ()->
                $('button[data-action=save]').button 'option', 'disabled', true if $input.val() isnt ''
                return
              if $input.data('val') in ['ins','out']
                $input.on 'keypress', (e)->
                  Wstm.desk.cache_book.linesInsert() if e.which is 13
            return
          return
        selects: (slcts)->
          slcts.each ()->
            $select = $(@)
            $sd = $select.data()
            if Trst.desk.hdo.dialog is 'filter'
              $select.on 'change', ()->
                $params = jQuery.param($('[data-mark~=param]').serializeArray())
                $url = "sys/wstm/cache_book/filter?#{$params}"
                Trst.desk.init($url)
                return
            return
          return
        buttons: (btns)->
          btns.each ()->
            $button = $(@)
            $bd = $button.data()
            if $button.hasClass('link')
              if Trst.desk.hdo.dialog is 'filter'
                $button.on 'click', ()->
                  if $bd.oid is 'nil'
                    $url = "sys/wstm/cache_book/create?id_date=#{$bd.id_date}"
                  else
                    $url = "sys/wstm/cache_book/#{$bd.oid}"
                  $.ajax({type: 'POST',url: '/sys/session/r_path/sys!wstm!cache_book!filter',async: false})
                  Trst.lst.setItem 'r_path', 'sys/wstm/cache_book/filter'
                  Trst.desk.init($url)
                  return
            else if $button.hasClass('fa-plus-circle')
              $button.off 'click'
              $button.on 'click', ()->
                Wstm.desk.cache_book.linesInsert()
                return
            else if $button.hasClass('fa-refresh')
              $button.off 'click'
              $button.on 'click', ()->
                Wstm.desk.cache_book.linesNewReset()
                return
            else if $button.hasClass('fa-minus-circle')
              $tr = $button.parentsUntil('tbody').last()
              $button.off 'click'
              $button.on 'click', ()->
                if Trst.desk.hdo.dialog is 'create'
                  $tr.remove()
                  Wstm.desk.cache_book.calculate()
                  Wstm.desk.cache_book.linesNewReset()
                if Trst.desk.hdo.dialog is 'edit'
                  if $tr.find('input[data-val=_id]').length
                    $tr.addClass('hidden')
                    $nested = $tr.find('input').last().clone()
                    $nested.attr('name', $nested.attr('name').replace('out','_destroy'))
                    $nested.val(1)
                    $tr.find('input').last().after($nested)
                    $tr.find('input').each ()->
                      $input = $(@)
                      $input.attr('name', $input.attr('name').replace(/(\d)/,'_$1') )
                  else
                    $tr.remove()
                  Wstm.desk.cache_book.calculate()
                  Wstm.desk.cache_book.linesNewReset()
                return
            return
          return
        init: ()->
          @buttons $('button, span.link, span.button')
          @selects $('select[data-mark~=param], input.select2, input.repair')
          @inputs $('input')
          @template = $('tr.template')?.remove()
          @linesNewReset()
          $log 'Wstm.desk.cache_book.init() OK...'
          return
  Wstm.desk.cache_book
