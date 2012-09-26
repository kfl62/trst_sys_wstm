define () ->
  $.extend true,Wstm,
    desk:
      grn:
        selectedDeliveryNotes: ()->
          dln_ary = []
          $('input:checked').each ()->
            dln_ary.push(@id)
            return
          $url = Trst.desk.hdf.attr('action')
          $url += "&p03=#{$('select#p03').val()}"
          $url += "&dln_ary=#{dln_ary}" if dln_ary.length
          Trst.desk.init($url)
          return
        inputs: (inpts)->
          inpts.each ()->
            $input = $(@)
            $id = $input.attr('id')
            $input.on 'change', ()->
              Wstm.desk.grn.selectedDeliveryNotes()
              return
            return
          return
        selects: (slcts)->
          slcts.each ()->
            $select = $(@)
            if $select.hasClass 'wstm'
              $select.on 'change', ()->
                $url  = Trst.desk.hdf.attr('action')
                $url += "&p03=#{$select.val()}" unless $select.val() is 'null'
                Trst.desk.init($url)
                return
            return
          return
        buttons: (btns)->
          btns.each ()->
            $button = $(@)
            $bd = $button.data()
            if Trst.desk.hdo.dialog is 'filter'
              $button.button 'option', 'disabled', true if $bd.action is 'create' and $('input:checked').length is 0
            return
          return
        init: ()->
          Wstm.desk.grn.buttons($('button'))
          Wstm.desk.grn.selects($('select.wstm'))
          Wstm.desk.grn.inputs($('input'))
          $log 'Wstm.desk.grn.init() OK...'
  Wstm.desk.grn
