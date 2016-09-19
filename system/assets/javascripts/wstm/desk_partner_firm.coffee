define () ->
  $.extend true,Wstm,
    desk:
      partner_firm:
        updateDocAry: (inpts)->
          inpts.filter(':checked').each ()->
            Wstm.desk.partner_firm.doc_ary.push(@id)
          inpts.filter('[data-mark="param doc_ary"]').val(@doc_ary)
          $params = jQuery.param($('[data-mark~="param"]').serializeArray())
          $url = "/sys/wstm/partner_firm/query?#{$params}"
          Trst.desk.init($url)
          return
        inputs: (inpts)->
          inpts.filter(':checkbox').on 'change', ()->
            Wstm.desk.partner_firm.updateDocAry(inpts)
        selects: (slcts)->
          slcts.each ()->
            $select = $(@)
            $sd = $select.data()
            $id = $select.attr('id')
            if $select.hasClass 'select2'
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
                    q: term
                  results: (data)->
                    results: data
              $select.unbind()
              $select.on 'change', ()->
                Trst.desk.hdo.oid = if $select.select2('val') is '' then null else $select.select2('val')
                return
            else
              $select.on 'click', ()->
                $('[data-mark~="doc_ary"]').val('') # if $(@).hasClass('firm')
                $params = jQuery.param($('[data-mark~="param"]').serializeArray())
                $url = "/sys/wstm/partner_firm/query?#{$params}"
                Trst.desk.init($url)
          return
        buttons: (btns)->
          btns.each ()->
            $button = $(@)
            $bd = $button.data()
            $id = $button.attr('id')
            if $bd.action is 'print'
              $button.on 'click', ()->
                Trst.msgShow Trst.i18n.msg.report.start
                $url  = "/sys/wstm/report/print?rb=yearly_stats"
                $url += "&fn=#{$bd.fn}" if $bd.fn
                $url += "&uid=#{$bd.uid}" if $bd.uid
                $.fileDownload $url,
                  successCallback: ()->
                    Trst.msgHide()
                  failCallback: ()->
                    Trst.msgHide()
                    Trst.desk.downloadError Trst.desk.hdo.model_name
                false
            if $bd.action is 'toggle_checkbox'
              $button.on 'click', ()->
                if $('input[data-mark="param doc_ary"]').val().split(',')[0] is "" or $('input[data-mark="param doc_ary"]').val().split(',').length < $('input:checkbox').length
                  $('input:checkbox').each ()->
                    Wstm.desk.partner_firm.doc_ary.push(@id)
                else
                  Wstm.desk.partner_firm.doc_ary = []
                $('input[data-mark="param doc_ary"]').val(Wstm.desk.partner_firm.doc_ary)
                $params = jQuery.param($('[data-mark~="param"]').serializeArray())
                $url = "/sys/wstm/partner_firm/query?#{$params}"
                Trst.desk.init($url)
                return
              return
            if Trst.desk.hdo.dialog is 'filter'
              if $bd.action in ['create','show','edit','delete']
                $bd.r_path = 'sys/wstm/partner_firm/filter'
            return
          return
        init: ()->
          @doc_ary = []
          @buttons $('button')
          @selects $('select[data-mark~="param"],input.select2')
          @inputs  $('input[data-mark~="doc_ary"]')
          $log 'Wstm.desk.partner_firm.init() OK...'
  Wstm.desk.partner_firm
