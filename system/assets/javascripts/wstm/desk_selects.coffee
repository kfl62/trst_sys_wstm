define () ->
  $.extend true,Wstm,
    desk:
      selects:
        handleUnit: (node)->
          $select = node
          $select.on 'change', ()->
            if $select.val() is 'null' then Wstm.unit_info.update() else Wstm.unit_info.update($select.find('option:selected').text())
            $model  = Trst.desk.hdo.js_ext.split(/_(.+)/)[1]
            $dialog = Trst.desk.hdo.dialog
            Trst.desk.init("/utils/units/wstm/#{$model}/#{$dialog}/#{$select.val()}")
            return
          return
        init: ()->
          @handleUnit($('select[data-mark~=unit]'))
          $log 'Wstm.selects.init() OK...'
  Wstm.desk.selects
