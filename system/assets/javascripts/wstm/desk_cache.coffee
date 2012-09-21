define () ->
  $.extend true,Wstm,
    desk:
      cache:
        init: ()->
          if Trst.desk.hdo.dialog is 'query'
            $sy = $('#y')
            $sm = $('#m')
            $su = $('#u')
            $('select').each ()->
              $select = $(@)
              $select.on 'change', ()->
                $url  = "sys/wstm/cache/query?y=#{$sy.val()}&m=#{$sm.val()}"
                $url += "&uid=#{$su.val()}" if $su.length
                Trst.desk.init($url)
                return
              return
            $('span.link').each ()->
              $link = $(@)
              $link.on 'click', ()->
                $url = "sys/wstm/cache/query?y=#{$sy.val()}&m=#{$sm.val()}&uid=#{$link.attr('id')}"
                Trst.desk.init($url)
                return
              return
          $log 'Wstm.desk.cache.init() OK...'
  Wstm.desk.cache
