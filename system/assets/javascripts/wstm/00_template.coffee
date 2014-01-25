define () ->
  $.extend true,Wstm,
    desk:
      template:
        calculate: ()->
          return
        inputs: (inpts)->
          inpts.each ()->
            $input = $(@)
            $ind = $input.data()
            return
          return
        selects: (slcts)->
          slcts.each ()->
            $select = $(@)
            $sd = $select.data()
            return
          return
        buttons: (btns)->
          btns.each ()->
            $button = $(@)
            $bd = $button.data()
            return
          return
        init: ()->
          Wstm.desk.template.buttons($('button'))
          Wstm.desk.template.selects($('select.param, input.select2, input.repair'))
          Wstm.desk.template.inputs($('input'))
          $log 'Wstm.desk.template.init() OK...'
          return
  Wstm.desk.template
