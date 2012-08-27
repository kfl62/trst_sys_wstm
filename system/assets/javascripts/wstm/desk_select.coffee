define () ->
  $.extend Wstm.desk.select,
    unit: (node) ->
      $select = node
      $select.change ()->
        if $select.val() is 'null' then Wstm.unit_info.update() else Wstm.unit_info.update($select.find('option:selected').text())
        Trst.desk.init("/utils/units/wstm/freight/#{$select.val()}")
        return
      return
    select2: (node) ->
      $select = node
      $sd = $select.data()
      $select.select2
        placeholder: "Selectaţi un #{Trst.desk.hdo.model}"
        minimumInputLength: $sd.minlength
        formatInputTooShort: (input, min)->
          Wstm.desk.select.inputTooShortMsg(input, min)
        formatSearching: ()->
          Wstm.desk.select.searchingMsg()
        formatNoMatches: (term)->
          Wstm.desk.select.noMatchesMsg(term)
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
    inputTooShortMsg: (input, min) ->
      $msg = "Vă rugăm întroduceţi min. " + (min - input.length) + " caractere" if input.length is 0
      $msg = "Vă rugăm întroduceţi incă " + (min - input.length) + " caractere" if input.length isnt 0
      $msg = "Vă rugăm întroduceţi incă 1 caracter"  if (min - input.length) is 1
      $msg
    searchingMsg: ()->
      $msg = 'Aveţi puţin tică răbdare...'
    noMatchesMsg: (term)->
      $msg = "Nu există ..."
    init: () ->
      if $('input.select2').length
        $('input.select2').each ()->
          Wstm.desk.select.select2($(this))
          return
        return
      if $('select.unit').length
        $('select.unit').each ()->
          Wstm.desk.select.unit($(this))
          return
        return
      $msg 'Wstm.select.init() OK...'
  return Wstm
