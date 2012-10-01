define () ->
  $.extend true,Wstm,
    desk:
      cache:
        init: ()->
          if $('#date_show').length
            now = new Date()
            min = if Trst.lst.admin is 'true' then new Date(now.getFullYear(),now.getMonth() - 1,1) else new Date(now.getFullYear(),now.getMonth(),1)
            $('#date_show').datepicker 'option', 'maxDate', '+0'
            $('#date_show').datepicker 'option', 'minDate', min
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
