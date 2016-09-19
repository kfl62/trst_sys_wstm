define () ->
  $.extend true,Wstm,
    desk:
      invoice:
        calculate: ()->
          # $rows  = $('tr.freight')
          # $total = $('tr.total')
          # tot_vi = 0
          # $rows.each ()->
          #   $tr = $(@)
          #   pu  = $tr.find('input[name*="pu"]').decFixed(4)
          #   qu  = $tr.find('input[name*="qu"]').decFixed(2)
          #   val = (parseFloat(pu.val()) * parseFloat(qu.val())).round(2)
          #   tot_vi += val
          #   $tr.find('span.val_invoice').text(val.toFixed(2))
          # $total.find('span.sum_100').text(tot_vi.toFixed(2))
          # $total.find('input[name*="sum_100"]').val(tot_vi.toFixed(2))
          # if tot_vi > 0
          #   $('button[data-action="save"]').button 'option', 'disabled', false
          # else
          #   $('button[data-action="save"]').button 'option', 'disabled', true
          # return
        updateDocAry: (inpts)->
          inpts.filter(':checked').each ()->
            Wstm.desk.invoice.doc_ary.push(@id)
          inpts.filter('[data-mark="param doc_ary"]').val(@doc_ary)
          $params = jQuery.param($('[data-mark~="param"]').serializeArray())
          $url = "/sys/wstm/invoice/filter?grn_ary=true&#{$params}" if $('[data-mark="param"]').filter('[name="supplr"]').length > 0
          $url = "/sys/wstm/invoice/filter?dln_ary=true&#{$params}" if $('[data-mark="param"]').filter('[name="client"]').length > 0
          Trst.desk.init($url)
          return
        inputs:  (inpts)->
          inpts.filter(':checkbox').on 'change', ()->
            Wstm.desk.invoice.updateDocAry(inpts)
          #   $input = $(@)
          #   $id = $input.attr('id')
          #   if $input.hasClass 'dln_ary'
          #     $input.on 'change', ()->
          #       Wstm.desk.invoice.selectedDeliveryNotes()
          #       return
          #   if $input.hasClass 'grn_ary'
          #     $input.on 'change', ()->
          #       Wstm.desk.invoice.selectedGrns()
          #       return
          #   if $input.attr('name')?.match(/([^\[^\]]+)/g).pop() is 'doc_name'
          #     if Trst.desk.hdo.title_data?
          #       $input.on 'change', ()->
          #           inpts.filter('[name*="\[name\]"]:not([type="hidden"])').val($(@).val())
          #           $('button[data-action="save"]').button 'option', 'disabled', false
          #         return
          #     else
          #       $input.on 'change', ()->
          #         if inpts.filter('[name*="pu\]"]:not([type="hidden"])').length
          #           inpts.filter('[name*="pu\]"]:not([type="hidden"])').first().focus()
          #         else
          #           $('button[data-action="save"]').button 'option', 'disabled', false
          #         return
          #   if $input.attr('name')?.match(/([^\[^\]]+)/g).pop() is 'pu'
          #     $input.on 'change', ()->
          #       Wstm.desk.invoice.calculate()
          #       return
          # return
        selects: (slcts)->
          slcts.each ()->
            $select = $(@)
            $sd = $select.data()
            $id = $select.attr('id')
            if $sd.mark is 'param'
              $select.on 'click', ()->
                $('[data-mark~="doc_ary"]').val('')
                $params = jQuery.param($('[data-mark~="param"]').serializeArray())
                $url = "/sys/wstm/invoice/filter?grn_ary=true&#{$params}" if $('[data-mark~="param"]').filter('[name="supplr"]').length > 0
                $url = "/sys/wstm/invoice/filter?dln_ary=true&#{$params}" if $('[data-mark~="param"]').filter('[name="client"]').length > 0
                Trst.desk.init($url)
          #   if $select.hasClass 'select2'
          #     if $id is 'client_id'
          #       $ph = Trst.i18n.select[Trst.desk.hdo.js_ext][$sd.ph]
          #       $select.select2
          #         placeholder: $ph
          #         minimumInputLength: $sd.minlength
          #         allowClear: true
          #         ajax:
          #           url: "/utils/search/#{$sd.search}"
          #           dataType: 'json'
          #           quietMillis: 100
          #           data: (term)->
          #             w: $id.split('_')[0]
          #             q: term
          #           results: (data)->
          #             results: data
          #       $select.select2('enable',false) if $('select[name="p03"]').val() is 'null'
          #       if Wstm.desk.tmp.client
          #         $select.select2('data',Wstm.desk.tmp.client)
          #         $dlg   = $select.next()
          #         $dlgsd = $dlg.data()
          #         $dlgph = Trst.i18n.select[Trst.desk.hdo.js_ext][$dlgsd.ph]
          #         $dlg.select2
          #           placeholder: $dlgph
          #           minimumInputLength: $dlgsd.minlength
          #           allowClear: true
          #           ajax:
          #             url: "/utils/search/#{$sd.search}"
          #             dataType: 'json'
          #             data: (term)->
          #               id: $select.select2('val')
          #             results: (data)->
          #               results: data
          #         $dlg.select2('data',Wstm.desk.tmp.client_d)
          #         $dlg.unbind()
          #         $dlg.on 'change', ()->
          #           if $dlg.select2('data')
          #             if $dlg.select2('data').id is 'new'
          #               $dlgadd = $dlg.next()
          #               $dlgadd.data('url','/sys/wstm/partner_firm/person')
          #               $dlgadd.data('r_id',$select.select2('val'))
          #               $dlgadd.data('r_mdl','firm')
          #               $dlgadd.show()
          #             else
          #               $dlg.next().hide()
          #           else
          #             $dlg.next().hide()
          #           Wstm.desk.invoice.validate.filter()
          #       $select.unbind()
          #       $select.on 'change', ()->
          #         if $select.select2('data')
          #           $select.next().select2('data',null)
          #           $select.next().select2('destroy')
          #           $dlg   = $select.next()
          #           $dlgsd = $dlg.data()
          #           $dlgph = Trst.i18n.select[Trst.desk.hdo.js_ext][$dlgsd.ph]
          #           $dlg.select2
          #             placeholder: $dlgph
          #             minimumInputLength: $dlgsd.minlength
          #             allowClear: true
          #             ajax:
          #               url: "/utils/search/#{$sd.search}"
          #               dataType: 'json'
          #               data: (term)->
          #                 id: $select.select2('val')
          #               results: (data)->
          #                 results: data
          #           $dlg.unbind()
          #           $dlg.on 'change', ()->
          #             if $dlg.select2('data')
          #               if $dlg.select2('data').id is 'new'
          #                 $dlgadd = $dlg.next()
          #                 $dlgadd.data('url','/sys/wstm/partner_firm/person')
          #                 $dlgadd.data('r_id',$select.select2('val'))
          #                 $dlgadd.data('r_mdl','firm')
          #                 $dlgadd.show()
          #               else
          #                 $dlg.next().hide()
          #             else
          #               $dlg.next().hide()
          #             Wstm.desk.invoice.validate.filter()
          #         else
          #           $select.next().select2('data',null)
          #           $select.next().select2('destroy')
          #           $select.next().next().hide()
          #         Wstm.desk.invoice.validate.filter()
          #     if $id is 'supplr_id'
          #       $ph = Trst.i18n.select[Trst.desk.hdo.js_ext][$sd.ph]
          #       $select.select2
          #         placeholder: $ph
          #         minimumInputLength: $sd.minlength
          #         allowClear: true
          #         ajax:
          #           url: "/utils/search/#{$sd.search}"
          #           dataType: 'json'
          #           quietMillis: 100
          #           data: (term)->
          #             w: $id.split('_')[0]
          #             q: term
          #           results: (data)->
          #             results: data
          #       $select.select2('enable',false) if $('select[name="p03"]').val() is 'null'
          #       if Wstm.desk.tmp.supplr
          #         $select.select2('data',Wstm.desk.tmp.supplr)
          #         $dlg   = $select.next()
          #         $dlgsd = $dlg.data()
          #         $dlgph = Trst.i18n.select[Trst.desk.hdo.js_ext][$dlgsd.ph]
          #         $dlg.select2
          #           placeholder: $dlgph
          #           minimumInputLength: $dlgsd.minlength
          #           allowClear: true
          #           ajax:
          #             url: "/utils/search/#{$sd.search}"
          #             dataType: 'json'
          #             data: (term)->
          #               id: $select.select2('val')
          #             results: (data)->
          #               results: data
          #         $dlg.select2('data',Wstm.desk.tmp.supplr_d)
          #         $dlg.unbind()
          #         $dlg.on 'change', ()->
          #           if $dlg.select2('data')
          #             if $dlg.select2('data').id is 'new'
          #               $dlgadd = $dlg.next()
          #               $dlgadd.data('url','/sys/wstm/partner_firm/person')
          #               $dlgadd.data('r_id',$select.select2('val'))
          #               $dlgadd.data('r_mdl','firm')
          #               $dlgadd.show()
          #             else
          #               $dlg.next().hide()
          #           else
          #             $dlg.next().hide()
          #           Wstm.desk.invoice.validate.filter()
          #       $select.unbind()
          #       $select.on 'change', ()->
          #         if $select.select2('data')
          #           $select.next().select2('data',null)
          #           $select.next().select2('destroy')
          #           $dlg   = $select.next()
          #           $dlgsd = $dlg.data()
          #           $dlgph = Trst.i18n.select[Trst.desk.hdo.js_ext][$dlgsd.ph]
          #           $dlg.select2
          #             placeholder: $dlgph
          #             minimumInputLength: $dlgsd.minlength
          #             allowClear: true
          #             ajax:
          #               url: "/utils/search/#{$sd.search}"
          #               dataType: 'json'
          #               data: (term)->
          #                 id: $select.select2('val')
          #               results: (data)->
          #                 results: data
          #           $dlg.unbind()
          #           $dlg.on 'change', ()->
          #             if $dlg.select2('data')
          #               if $dlg.select2('data').id is 'new'
          #                 $dlgadd = $dlg.next()
          #                 $dlgadd.data('url','/sys/wstm/partner_firm/person')
          #                 $dlgadd.data('r_id',$select.select2('val'))
          #                 $dlgadd.data('r_mdl','firm')
          #                 $dlgadd.show()
          #               else
          #                 $dlg.next().hide()
          #             else
          #               $dlg.next().hide()
          #             Wstm.desk.invoice.validate.filter()
          #         else
          #           $select.next().select2('data',null)
          #           $select.next().select2('destroy')
          #           $select.next().next().hide()
          #         Wstm.desk.invoice.validate.filter()
            if $select.hasClass 'repair'
              $ph = Trst.i18n.select[Trst.desk.hdo.js_ext][$sd.ph]
              $select.select2
                placeholder: $ph
                allowClear: true
                quietMillis: 1000
                ajax:
                  url: "/utils/search/#{$sd.search}"
                  dataType: 'json'
                  data: (term)->
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
              if $bd.action is 'toggle_checkbox'
                $button.on 'click', ()->
                  if $('input[data-mark="param doc_ary"]').val().split(',')[0] is "" or $('input[data-mark="param doc_ary"]').val().split(',').length < $('input:checkbox').length
                    $('input:checkbox').each ()->
                      Wstm.desk.invoice.doc_ary.push(@id)
                  else
                    Wstm.desk.invoice.doc_ary = []
                  $('input[data-mark="param doc_ary"]').val(Wstm.desk.invoice.doc_ary)
                  $params = jQuery.param($('[data-mark~="param"]').serializeArray())
                  $url = "/sys/wstm/invoice/filter?grn_ary=true&#{$params}" if $('[data-mark~="param"]').filter('[name="supplr"]').length > 0
                  $url = "/sys/wstm/invoice/filter?dln_ary=true&#{$params}" if $('[data-mark~="param"]').filter('[name="client"]').length > 0
                  Trst.desk.init($url)
                  return
              if $bd.action is 'create'
                $url = Trst.desk.hdf.attr('action')
                if $('[data-mark~="param"]').filter('[name="supplr"]').length > 0
                  $url += "/create?supplr_id=#{$('[data-mark~="param"]').filter('[name="supplr"]').val()}"
                  $url += "&grn_ary=#{$('[data-mark~="param"]').filter('[name="doc_ary"]').val()}"
                if $('[data-mark~="param"]').filter('[name="client"]').length > 0
                  $url += "/create?client_id=#{$('[data-mark~="param"]').filter('[name="client"]').val()}"
                  $url += "&dln_ary=#{$('[data-mark~="param"]').filter('[name="doc_ary"]').val()}"
                $bd.url = $url
              return
            if Trst.desk.hdo.dialog is 'show'
              if $bd.action is 'print'
                $button.on 'click', ()->
                  Trst.msgShow Trst.i18n.msg.report.start
                  $.fileDownload "/sys/wstm/invoice/print?id=#{Trst.desk.hdo.oid}",
                    successCallback: ()->
                      Trst.msgHide()
                    failCallback: ()->
                      Trst.msgHide()
                      Trst.desk.downloadError Trst.desk.hdo.model_name
                  return
                return
            if Trst.desk.hdo.dialog is 'repair'
              $button.focus()
              return
          return
        init: ()->
          @doc_ary = []
          @buttons($('button'))
          @selects($('select,input.select2,input.repair'))
          @inputs($('input[data-mark~="doc_ary"]'))
          $log 'Wstm.desk.invoice.init() OK...'
  Wstm.desk.invoice
