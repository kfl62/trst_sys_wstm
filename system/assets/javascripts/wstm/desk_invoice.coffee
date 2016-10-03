define () ->
  $.extend true,Wstm,
    desk:
      invoice:
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
          @selects($('select,input.select2,input[data-mark~="repair"]'))
          @inputs($('input[data-mark~="doc_ary"]'))
          $log 'Wstm.desk.invoice.init() OK...'
  Wstm.desk.invoice
