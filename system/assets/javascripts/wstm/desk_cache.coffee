define () ->
  $.extend true,Wstm,
    desk:
      cache:
        inputs: (inpts)->
          inpts.each ()->
            $input = $(@)
            $ind = $input.data()
            return
          return
        selects: (slcts)->
          slcts.each ()->
            $select = $(@)
            $sd = $select.data()
            if Trst.desk.hdo.dialog is 'query'
              $select.on 'change', ()->
                $params = jQuery.param($('.param').serializeArray())
                $url  = "sys/wstm/cache/query?#{$params}"
                Trst.desk.init($url)
                return
            return
          return
        buttons: (btns)->
          btns.each ()->
            $button = $(@)
            $bd = $button.data()
            if Trst.desk.hdo.dialog is 'query'
              $button.on 'click', ()->
                $params = jQuery.param($('.param').serializeArray())
                $url = "sys/wstm/cache/query?#{$params}&uid=#{$button.attr('id')}"
                Trst.desk.init($url)
                return
            return
          return
        init: ()->
          @buttons $('span.link')
          @selects $('select')
          $log 'Wstm.desk.cache.init() OK...'
  Wstm.desk.cache
