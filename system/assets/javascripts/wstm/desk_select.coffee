define () ->
  $.extend Wstm.desk.select,
    unit: () ->
      $msg 'Wstm unit'
    init: () ->
      $select = $('select.unit').change ()->
        if $select.val() is 'null' then Wstm.unit_info.update() else Wstm.unit_info.update($select.find('option:selected').text())
        #Trst.desk.closeDesk()
        Trst.desk.init("/utils/units/wstm/freight/#{$select.val()}")
        return
      $msg 'Wstm.select.init() OK...'
  return Wstm
