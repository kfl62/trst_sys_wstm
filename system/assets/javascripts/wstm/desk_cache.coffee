define () ->
  $.extend true,Wstm,
    desk:
      cache:
        init: ()->
          $sy = $('#y')
          $sm = $('#m')
          $su = $('#u')
          $('select').each ()->
            $select = $(this)
            $select.on 'change', ()->
              $url  = "sys/wstm/cache/query?y=#{$sy.val()}&m=#{$sm.val()}"
              $url += "#{$url}&uid=#{$su.val()}" if $su.length
              Trst.desk.init($url)
              return
            return
          $('span.link').each ()->
            $link = $(this)
            $link.on 'click', ()->
              $url = "sys/wstm/cache/query?y=#{$sy.val()}&m=#{$sm.val()}&uid=#{$link.attr('id')}"
              Trst.desk.init($url)
              return
            return
          $msg 'Wstm.desk.cache.init() OK...'
  Wstm
