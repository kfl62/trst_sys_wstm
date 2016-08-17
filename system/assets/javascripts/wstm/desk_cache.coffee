define () ->
  $.extend true,Wstm,
    desk:
      cache:
        selects: (slcts)->
          slcts.each ()->
            $select = $(@)
            $sd = $select.data()
            if Trst.desk.hdo.dialog is 'query'
              $select.on 'change', ()->
                $params = jQuery.param($('[data-mark~=param]').serializeArray())
                $url  = "sys/wstm/cache/query?#{$params}"
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
                $bd.r_path = 'sys/wstm/cache/filter'
            return
          return
        init: ()->
          @buttons $('button, span.link')
          @selects $('select')
          $log 'Wstm.desk.cache.init() OK...'
  Wstm.desk.cache
