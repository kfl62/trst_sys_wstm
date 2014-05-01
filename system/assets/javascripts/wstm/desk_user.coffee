define () ->
  $.extend true,Wstm,
    desk:
      user:
        selects: (slcts)->
          slcts.each ()->
            $select = $(@)
            $sd = $select.data()
            if $select.hasClass 'select2'
              $select.select2
                placeholder: 'Selectaţi min. un gestionar...'
                minimumInputLength: 0
                multiple: true
                data: $sd.data
              $select.on 'change', ()->
                if $select.select2('val').length
                  $('.query').button 'option', 'disabled', false
                else
                  $('.query').button 'option', 'disabled', true
                return
              return
          return
        buttons: (btns)->
          btns.each ()->
            $button = $(@)
            $bd = $button.data()
            if $button.hasClass 'query'
              $button.button 'option', 'disabled', true
              $button.on 'click', ()->
                $params = jQuery.param($('.param').serializeArray())
                $url    = "/sys/wstm/user/query?#{$params}"
                Trst.desk.init($url)
            if $button.hasClass 'print'
              $button.on 'click', ()->
                Trst.msgShow Trst.i18n.msg.report.start
                $url    = "/sys/wstm/user/print?#{$bd.url}"
                $.fileDownload $url,
                  successCallback: ()->
                    Trst.msgHide()
                  failCallback: ()->
                    Trst.msgHide()
                    Trst.desk.downloadError Trst.desk.hdo.model_name
                return
            return
          return
        init: ()->
          Wstm.desk.user.buttons($('button'))
          Wstm.desk.user.selects($('select.param,input.select2'))
          $log 'Wstm.desk.report.init() OK...'
  Wstm.desk.user
