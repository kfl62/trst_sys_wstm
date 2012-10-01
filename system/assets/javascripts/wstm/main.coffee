define (['/javascripts/libs/select2.min.js','/javascripts/libs/jquery.ui.datepicker-ro.js','wstm/desk']), ()->
  $.extend Wstm,
    unit_info:
      node:  ()->
        $("<hr>
           <li class='em st'>#{ Trst.i18n.unit_info_lbl}</li>
           <li id='unit_info'>#{ Trst.lst.unit_info_txt}</>")
      update: (unit_name = null)->
        if unit_name is null then Trst.lst.unit_info_txt = Trst.i18n.unit_info_all else Trst.lst.unit_info_txt = unit_name
        if $('body').data('admin')
          if $('#unit_info').length
            $('#unit_info').text(Trst.lst.unit_info_txt)
          else
            $('#xhr_tasks ul li').last().append(Wstm.unit_info.node())
        Wstm.unit_info_text
    init: () ->
      Trst.lst.setItem 'admin', $('body').data('admin')
      $('#menu.system ul li a').filter('[id^="page"]').unbind()
      $('#menu.system ul li a').filter('[id^="page"]').click ()->
        $page_id = $(@).attr('id').split('_')[1]
        $('#xhr_tasks').load "/sys/tasks/#{$page_id}", ()->
          Trst.lst.setItem 'page_id', $page_id
          Wstm.unit_info.update(Trst.lst.unit_info_txt)
        false
      if Trst.lst.page_id
        $('#xhr_tasks').load "/sys/tasks/#{Trst.lst.page_id}", ()->
          Wstm.unit_info.update(Trst.lst.unit_info_txt)
      $log "Wstm init() OK..."
  Wstm
