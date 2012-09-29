define () ->
  $.extend true,Wstm,
    desk:
      grn:
        validate:
          filter: ()->
            return
          create: ()->
            if $('input#transp_d_id').select2('val') is '' or $('input#transp_d_id').select2('val') is 'new'
              $('button[data-action="save"]').button 'option', 'disabled', true
              return false
            else
              $('button[data-action="save"]').button 'option', 'disabled', false
              return true
        selectedDeliveryNotes: ()->
          @dln_ary = []
          $('input:checked').each ()->
            Wstm.desk.grn.dln_ary.push(@id)
            return
          $url = Trst.desk.hdf.attr('action')
          $url += "&p03=#{$('select#p03').val()}"
          $url += "&dln_ary=#{Wstm.desk.grn.dln_ary}" if Wstm.desk.grn.dln_ary.length
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
            $sd = $select.data()
            $id = $select.attr('id')
            if $select.hasClass 'wstm'
              $select.on 'change', ()->
                $url  = Trst.desk.hdf.attr('action')
                $url += "&p03=#{$select.val()}" unless $select.val() is 'null'
                Trst.desk.init($url)
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
            return
          return
        init: ()->
          Wstm.desk.grn.buttons($('button'))
          Wstm.desk.grn.selects($('select.wstm, input.select2'))
          Wstm.desk.grn.inputs($('input.dln_ary'))
          $log 'Wstm.desk.grn.init() OK...'
  Wstm.desk.grn
