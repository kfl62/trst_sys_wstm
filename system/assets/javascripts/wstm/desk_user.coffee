define () ->
  $.extend true,Wstm,
    desk:
      user:
        selects: (slcts)->
          slcts.each ()->
            $select = $(@)
            $sd = $select.data()
            if $('[data-mark~="s2"]')
              $select.select2
                placeholder: 'Selectaţi min. un gestionar...'
                minimumInputLength: 0
                multiple: true
                data: $sd.data
              $select.on 'change', ()->
                if $select.select2('val').length
                  $('[data-action~="query"][type="button"]').button 'option', 'disabled', false
                else
                  $('[data-action~="query"][type="button"]').button 'option', 'disabled', true
                return
              return
          return
        buttons: (btns)->
          btns.each ()->
            $button = $(@)
            $bd = $button.data()
            if $bd.action is 'query'
              $button.button 'option', 'disabled', true
              $button.on 'click', ()->
                $params = jQuery.param($('[data-mark~=param]').serializeArray())
                $url    = "/sys/wstm/user/query?#{$params}"
                Trst.desk.init($url)
                return
              return
          return
        init: ()->
          @buttons($('button'))
          @selects($('select.param,input.select2'))
          $log 'Wstm.desk.report.init() OK...'
  Wstm.desk.user
