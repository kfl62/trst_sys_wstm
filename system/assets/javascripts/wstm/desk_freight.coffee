define () ->
  $.extend true,Wstm,
    desk:
      freight:
        handleFreight: ()->
          $sy = $('#y')
          $sm = $('#m')
          $sf = $('#f')
          $('select').each ()->
            $select = $(@)
            $select.on 'change', ()->
              $url  = "sys/wstm/freight/query?y=#{$sy.val()}&m=#{$sm.val()}&uid=#{$sf.data('uid')}&fid=#{$sf.val()}"
              Trst.desk.init($url)
              return
            return
          return
        handleNoFreight: ()->
          $sy = $('#y')
          $sm = $('#m')
          $su = $('#u')
          $('select').each ()->
            $select = $(@)
            $select.on 'change', ()->
              $url  = "sys/wstm/freight/query?y=#{$sy.val()}&m=#{$sm.val()}"
              $url += "#{$url}&uid=#{$su.val()}" if $su.length
              Trst.desk.init($url)
              return
            return
          $('span.link').each ()->
            $link = $(@)
            $link.on 'click', ()->
              $url = "sys/wstm/freight/query?y=#{$sy.val()}&m=#{$sm.val()}"
              if $su.length
                $url += "#{$url}&uid=#{$su.val()}&fid=#{$link.attr('id')}"
              else
                $url += if $link.hasClass('uid') then "#{$url}&uid=#{$link.attr('id')}" else "#{$url}&fid=#{$link.attr('id')}"
              Trst.desk.init($url)
              return
            return
          return
        init: ()->
          if Trst.desk.hdo.dialog is 'query'
            if $('p.noFreight').length
              Wstm.desk.freight.handleNoFreight()
            if $('p.hasFreight').length
              Wstm.desk.freight.handleFreight()
          $log 'Wstm.desk.freight.init() OK...'
  Wstm.desk.freight
