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
          autoSize: true
          $.datepicker.regional['ro']
      $model = Trst.desk.hdf.attr('action').split('/').pop(-1)
      if $model is 'expenditure'
        require (['wstm/desk_expenditure']), () ->
          Wstm.desk.expenditure.init()
      $msg 'Wstm.desk.init() Ok...'
  return Wstm
