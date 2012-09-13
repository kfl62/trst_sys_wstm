define () ->
  $.extend true,Wstm,
    desk:
      select:
        unit: (node)->
          $select = node
          $select.change ()->
            if $select.val() is 'null' then Wstm.unit_info.update() else Wstm.unit_info.update($select.find('option:selected').text())
            $model  = Trst.desk.hdo.js_ext.split('_')[1]
            $dialog = Trst.desk.hdo.dialog
            Trst.desk.init("/utils/units/wstm/#{$model}/#{$dialog}/#{$select.val()}")
            return
          return
        select2: (node)->
          $select = node
          $sd = $select.data()
          $.extend true, $.fn.select2.defaults,
            placeholder: "Selectaţi un #{Trst.desk.hdo.model}"
            minimumInputLength: $sd.minlength
            formatInputTooShort: (input, min)->
              Wstm.desk.select.inputTooShortMsg(input, min)
            formatSearching: ()->
              Wstm.desk.select.searchingMsg()
            formatNoMatches: (term)->
              Wstm.desk.select.noMatchesMsg(term)
          unless $sd.noinit
            $select.select2
              ajax:
                url: "/utils/search/#{$sd.model}"
                dataType: 'json'
                quietMillis: 1000
                data: (term)->
                  q: term
                results: (data)->
                  results: data
          $select.on 'change', ()->
            Trst.desk.hdo.oid = $select.select2('val')
            return
          return
        inputTooShortMsg: (input, min)->
          $msg = "Vă rugăm întroduceţi min. " + (min - input.length) + " caractere" if input.length is 0
          $msg = "Vă rugăm întroduceţi incă " + (min - input.length) + " caractere" if input.length isnt 0
          $msg = "Vă rugăm întroduceţi incă 1 caracter"  if (min - input.length) is 1
          $msg
        searchingMsg: ()->
          $msg = 'Aveţi puţin tică răbdare...'
        noMatchesMsg: (term)->
          $msg = "Nu există ..."
        init: () ->
          $('select.wstm, input.select2').each ()->
            $select =  $(this)
            if $select.hasClass('select2')
              Wstm.desk.select.select2($select)
            else if $select.hasClass('unit')
              Wstm.desk.select.unit($select)
            else
              $msg 'Unknown class for select...'
            return
          $msg 'Wstm.select.init() OK...'
  Wstm
