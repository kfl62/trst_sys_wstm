define (['wstm/desk']), () ->
  $.extend Wstm,
    unit_info:
      label: 'Punctul de colectare selectat:'
      text:  'Toate unităţile'
      node:  () ->
        $("<hr>
           <li class='em st'>#{ Wstm.unit_info.label}</li>
           <li id='unit_info'>#{ Wstm.unit_info.text}</>")
      update: (unit_name = null) ->
        if unit_name is null then Wstm.unit_info.text = 'Toate unităţile' else Wstm.unit_info.text = unit_name
        if $('body').data('unit_id')
          if $('#unit_info').length
            $('#unit_info').text(Wstm.unit_info.text)
          else
            $('#xhr_tasks ul li').last().append(Wstm.unit_info.node())
        Wstm.unit_info.text
    init: () ->
      $('#menu.system ul li a').filter('[id^="page"]').unbind()
      $('#menu.system ul li a').filter('[id^="page"]').click ->
        $('#xhr_tasks').load "/sys/tasks/#{$(this).attr('id').split('_')[1]}",
                             () -> Wstm.unit_info.update(Wstm.unit_info.text)
        false
      $msg "Wstm init() OK..."
  return Wstm
