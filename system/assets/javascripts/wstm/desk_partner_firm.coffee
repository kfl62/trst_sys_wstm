define () ->
  $.extend true,Wstm,
    desk:
      partner_firm:
        init: ()->
          $('input.select2')?.each ()->
            $select = $(@)
            $sd = $select.data()
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
            return
          $('select#y')?.each ()->
            $select = $(@)
            $select.unbind()
            $select.on 'change', ()->
              $url = "/sys/wstm/partner_firm/query?y=#{$select.val()}"
              Trst.desk.init($url)
              return
            return
          $log 'Wstm.desk.partner_firm.init() OK...'
          $('button').each ()->
            $button = $(@)
            $bd = $button.data()
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
  Wstm.desk.partner_firm
