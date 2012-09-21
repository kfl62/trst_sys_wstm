define () ->
  $.extend true,Wstm,
    desk:
      select:
        unit: (node)->
          $select = node
          $select.change ()->
            if $select.val() is 'null' then Wstm.unit_info.update() else Wstm.unit_info.update($select.find('option:selected').text())
            $model  = Trst.desk.hdo.js_ext.split(/_(.+)/)[1]
            $dialog = Trst.desk.hdo.dialog
            Trst.desk.init("/utils/units/wstm/#{$model}/#{$dialog}/#{$select.val()}")
            return
          return
        select2: (node)->
          $select = node
          $sd = $select.data()
          if Trst.desk.hdo.js_ext
            $ph = Trst.i18n.select[Trst.desk.hdo.js_ext][$sd.ph] || Trst.i18n.select[Trst.desk.hdo.js_ext][0]
          else
            $ph = Trst.i18n.select.placeholder.replace '%{data}', Trst.desk.hdo.model_name
          $.extend true, $.fn.select2.defaults,
            placeholder: $ph
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
                url: "/utils/search/#{$sd.search}"
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
          $msg = Trst.i18n.msg.input_too_short_strt.replace '%{nr}', (min - input.length) if input.length is 0
          $msg = Trst.i18n.msg.input_too_short_more.replace '%{nr}', (min - input.length) if input.length isnt 0
          $msg = Trst.i18n.msg.input_too_short_last if (min - input.length) is 1
          $msg
        searchingMsg: ()->
          $msg = Trst.i18n.msg.searching
        noMatchesMsg: (term)->
          $msg = Trst.i18n.msg.no_matches
        init: () ->
          $('select.wstm, input.select2').each ()->
            $select =  $(@)
            if $select.hasClass('select2')
              Wstm.desk.select.select2($select)
            else if $select.hasClass('unit')
              Wstm.desk.select.unit($select)
            else if $select.hasClass('freight')
              ###
              Handled by Wstm.desk.expenditure|delivery_note...
              ###
            else
              $log 'Unknown class for select...'
            return
          $log 'Wstm.select.init() OK...'
  Wstm.desk.select
