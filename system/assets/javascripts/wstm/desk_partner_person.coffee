define () ->
  $.extend true,Wstm,
    desk:
      partner_person:
        updateDocAry: (inpts)->
          @doc_ary = []
          inpts.filter(':checked').each ()->
            Wstm.desk.partner_person.doc_ary.push(@id)
          inpts.filter('[data-mark="param doc_ary"]').val(@doc_ary)
          $params = jQuery.param($('[data-mark~="param"]').serializeArray())
          $url = "/sys/partial/wstm/partner_person/_query_expenditures?#{$params}"
          Trst.msgShow()
          $('td.query-expenditures-container').load $url, ()->
            Wstm.desk.partner_person.selects($('select[data-mark~="param"]'))
            Wstm.desk.partner_person.inputs($('input'))
            Trst.msgHide()
            return
          return
        inputs: (inpts)->
          inpts.filter(':checkbox').on 'change', ()->
            Wstm.desk.partner_person.updateDocAry(inpts)
            return
          return
        selects: (slcts)->
          slcts.each ()->
            $select = $(@)
            $sd = $select.data()
            if $select.hasClass 'select2'
              $ph = Trst.i18n.select[Trst.desk.hdo.js_ext][$sd.ph]
              $select.select2
                placeholder: $ph
                minimumInputLength: $sd.minlength
                allowClear: true
                ajax:
                  url: "/utils/search/#{$sd.search}"
                  dataType: 'json'
                  quietMillis: 100
                  data: (term)->
                    q: term
                  results: (data)->
                    results: data
              $select.unbind()
              $select.on 'change', ()->
                if $select.select2('val') is ''
                  Trst.desk.hdo.oid = null
                  if Trst.desk.hdo.dialog is 'query'
                    $url = "/sys/wstm/partner_person/query"
                    Trst.desk.init($url)
                    return
                  return
                else
                  Trst.desk.hdo.oid = $select.select2('val')
                  if Trst.desk.hdo.dialog is 'query'
                    $params = jQuery.param($('[data-mark~="param"]').serializeArray())
                    $url = "/sys/partial/wstm/partner_person/_query_expenditures?#{$params}"
                    Trst.msgShow()
                    $('td.query-expenditures-container').load $url, ()->
                      Wstm.desk.partner_person.selects($('select[data-mark~="param"]'))
                      Wstm.desk.partner_person.inputs($('input'))
                      Trst.msgHide()
                      return
                    return
                  return
                return
              return
            else
              $select.on 'change', ()->
                $('[data-mark~="param doc_ary"]').val('')
                $params = jQuery.param($('[data-mark~="param"]').serializeArray())
                $url = "/sys/partial/wstm/partner_person/_query_expenditures?#{$params}"
                Trst.msgShow()
                $('td.query-expenditures-container').load $url, ()->
                  Wstm.desk.partner_person.selects($('select[data-mark~="param"]'))
                  Wstm.desk.partner_person.inputs($('input'))
                  Trst.msgHide()
                  return
              return
            return
          return
        buttons: (btns)->
          btns.each ()->
            $button = $(@)
            $bd = $button.data()
            if Trst.desk.hdo.dialog is 'filter'
              if $bd.action in ['create','show','edit','delete']
                $bd.r_path = 'sys/wstm/partner_person/filter'
            return
          return
        init: ()->
          @buttons($('button'))
          @selects($('select[data-mark~="param"],input.select2,input.repair'))
          @inputs($('input[data-mark~="doc_ary"],input'))
          $log 'Wstm.desk.partner_person.init() OK...'
  Wstm.desk.partner_person
