define () ->
  $.extend Wstm.desk,
    init: () ->
      if $('select.wstm').length
        require (['wstm/desk_select']), () ->
          Wstm.desk.select.init()
      $msg 'Wstm.desk.init() Ok...'
  return Wstm
