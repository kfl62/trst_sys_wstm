define () ->
  $.extend true,Wstm,
    desk:
      tmp:
        set: (key,value)->
          if @[key] or @[key] is 0 then @[key] else @[key] = value
        clear: (what...)->
          $.each @, (k)=>
            if what.length
              delete @[k] if k in [what...]
            else
              delete @[k] unless k in ['set','clear']
      init: () ->
        $log 'Wstm.desk.init() Ok...'
        if $('select[data-mark~=wstm]').length
          require (['wstm/desk_selects']), (selects)->
            selects.init()
        if $ext = Trst.desk.hdo.js_ext
          require (["wstm/#{$ext}"]), (ext)->
            ext.init()
        return
  Wstm.desk
