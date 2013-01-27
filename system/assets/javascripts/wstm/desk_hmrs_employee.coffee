define () ->
  $.extend true,Wstm,
    desk:
      hmrs_employee:
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
          $('button').each ()->
            $button = $(@)
            $bd = $button.data()
            if $bd.action is 'print'
              $button.on 'click', ()->
                Trst.msgShow Trst.i18n.msg.report.start
                $url  = "/sys/wstm/hmrs/employee/print?id=#{Trst.desk.hdo.oid}"
                $url += "&fn=#{$bd.fn}" if $bd.fn
                $url += "&ch_id=#{$bd.ch_id}" if $bd.ch_id
                $.fileDownload $url,
                  successCallback: ()->
                    Trst.msgHide()
                  failCallback: ()->
                    Trst.msgHide()
                    Trst.desk.downloadError Trst.desk.hdo.model_name
                false
          $log 'Wstm.desk.hmrs_employee.init() OK...'
  Wstm.desk.hmrs_employee
