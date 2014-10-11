define () ->
  $.extend true,Wstm,
    desk:
      freight:
        handleFreight: ()->
          $('select').each ()->
            $select = $(@)
            $select.on 'change', ()->
              $params = jQuery.param($('[data-mark~=param]').serializeArray())
              $url  = "sys/wstm/freight/query?#{$params}"
              Trst.desk.init($url)
              return
            return
          return
        handleNoFreight: ()->
          $('select').each ()->
            $select = $(@)
            $select.on 'change', ()->
              $params = jQuery.param($('[data-mark~=param]').serializeArray())
              $url  = "sys/wstm/freight/query?#{$params}"
              Trst.desk.init($url)
              return
            return
          if Trst.desk.hdo.dialog is 'query'
            $('span.link').each ()->
              $link = $(@)
              $link.on 'click', ()->
                $params = jQuery.param($('[data-mark~=param]').serializeArray())
                $url = "sys/wstm/freight/query?#{$params}"
                $url += if $link.hasClass('uid') then "&uid=#{$link.attr('id')}" else "&fid=#{$link.attr('id')}"
                Trst.desk.init($url)
                return
              return
          return
        buttons: (btns)->
          btns.each ()->
            $button = $(@)
            $bd = $button.data()
            if Trst.desk.hdo.dialog is 'filter'
              if $bd.action in ['create','show','edit','delete']
                $bd.r_path = 'sys/wstm/freight/filter'
          return
        init: ()->
          @buttons $('button')
          if Trst.desk.hdo.dialog in ['query','query_value']
            if $('#xhr_info').hasClass 'noFreight'
              @handleNoFreight()
            if $('#xhr_info').hasClass 'hasFreight'
              @handleFreight()
          $log 'Wstm.desk.freight.init() OK...'
  Wstm.desk.freight
