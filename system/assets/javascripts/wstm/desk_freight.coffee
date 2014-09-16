define () ->
  $.extend true,Wstm,
    desk:
      freight:
        handleFreight: ()->
          $('select').each ()->
            $select = $(@)
            $select.on 'change', ()->
              $params = jQuery.param($('.param').serializeArray())
              $url  = "sys/wstm/freight/query?#{$params}"
              Trst.desk.init($url)
              return
            return
          return
        handleNoFreight: ()->
          $('select').each ()->
            $select = $(@)
            $select.on 'change', ()->
              $params = jQuery.param($('.param').serializeArray())
              $url  = "sys/wstm/freight/query?#{$params}"
              Trst.desk.init($url)
              return
            return
          if Trst.desk.hdo.dialog is 'query'
            $('span.link').each ()->
              $link = $(@)
              $link.on 'click', ()->
                $params = jQuery.param($('.param').serializeArray())
                $url = "sys/wstm/freight/query?#{$params}"
                $url += if $link.hasClass('uid') then "&uid=#{$link.attr('id')}" else "&fid=#{$link.attr('id')}"
                Trst.desk.init($url)
                return
              return
          return
        init: ()->
          if Trst.desk.hdo.dialog in ['query','query_value']
            if $('#xhr_info').hasClass 'noFreight'
              Wstm.desk.freight.handleNoFreight()
            if $('#xhr_info').hasClass 'hasFreight'
              Wstm.desk.freight.handleFreight()
          $log 'Wstm.desk.freight.init() OK...'
  Wstm.desk.freight
