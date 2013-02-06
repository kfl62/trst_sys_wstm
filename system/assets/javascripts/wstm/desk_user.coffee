define () ->
  $.extend true,Wstm,
    desk:
      user:
        init: ()->
          $('#user_ids').select2
            placeholder: 'Selectaţi min. un gestionar...'
            minimumInputLength: 0
            multiple: true
            data: $('#user_ids').data('data')
          $('#user_ids').on 'change', ()->
            if $(@).select2('val').length
              $('button.query').button 'option', 'disabled', false
            else
              $('button.query').button 'option', 'disabled', true
          $('button.query').on 'click', ()->
            $url  = '/sys/wstm/user/query'
            $url += "?y=#{$('#y').val()}&m=#{$('#m').val()}"
            $url += "&user_ids=#{$('#user_ids').select2('val')}" if $('#user_ids').select2('val').length
            Trst.desk.init($url)
          $('button.query').button 'option', 'disabled', true
          $('button.print').button 'option', 'disabled', true
          $log 'Wstm.desk.report.init() OK...'
  Wstm.desk.user
