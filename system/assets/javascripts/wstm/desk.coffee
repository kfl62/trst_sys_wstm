define () ->
  $.extend Wstm.desk,
    init: () ->
      if $('select.wstm, input.select2').length
        require (['wstm/desk_select']), () ->
          Wstm.desk.select.init()
      if $('#date_show').length
        $('#date_show').datepicker
          altField: '#date_send'
          altFormat: 'yy-mm-dd'
          $.datepicker.regional['ro']
      $msg 'Wstm.desk.init() Ok...'
  return Wstm
