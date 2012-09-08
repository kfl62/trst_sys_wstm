define () ->
  $.extend true,Wstm,
    desk:
      expenditure:
        noMatchesMsg: (term)->
          $button = $('button.partner-person')
          $button.unbind()
          if term.length < 13
            $button.button 'option', 'disabled', true
            $msg = "Acest client nu există! Introduceţi un CNP valid format din 13 cifre, incă (#{13 - term.length}) cifre!"
          else if term.length is 13
            if Wstm.desk.idPnValidate(term)
              $button.button 'option', 'disabled', false
              $url = "/sys/wstm/partner_person/create?id_pn=#{term}"
              $button.on 'click', ()->
                Trst.desk.closeDesk()
                Trst.desk.init($url)
              $msg = 'CNP valid. Apăsaţi "Creare Persoană Fizică!"'
            else
              $button.button 'option', 'disabled', true
              $msg = "CNP invalid! Mai încercaţi :)"
          else
            $button.button 'option', 'disabled', true
            $msg = 'CNP-ul nu poate fi mai lung de 13 cifre!'
        calculate: ()->
          $rows  = $('tr.freight')
          $total = $('tr.total')
          tot_val = 0; tot_p03 = 0; tot_p16 = 0; tot_res = 0
          $rows.each ()->
            $tr = $(this)
            $sd = $tr.find('select').find('option:selected').data()
            pu  = $tr.find('input[name*="pu"]').decFixed(2)
            qu  = $tr.find('input[name*="qu"]').decFixed(2)
            val = (parseFloat(pu.val()) * parseFloat(qu.val())).round(2)
            p03 = if $sd.p03 then (val * 0.03).round(2) else 0
            p16 = (val * 0.16).round(2)
            res = (val - p03 - p16).round(2)
            tot_val += val; tot_p03 += p03; tot_p16 += p16; tot_res += res
            $tr.find('span.val').text(val.toFixed(2))
            $tr.find('span.p03').text(p03.toFixed(2))
            $tr.find('span.p16').text(p16.toFixed(2))
            $tr.find('span.res').text(res.toFixed(2))
            $tr.find('input[name*="val"]').val(val.toFixed(2))
            return
          $total.find('span.val').text(tot_val.toFixed(2))
          $total.find('span.p03').text(tot_p03.toFixed(2))
          $total.find('span.p16').text(tot_p16.toFixed(2))
          $total.find('span.res').text(tot_res.toFixed(2))
          $total.find('input[name*="sum_100"]').val(tot_val.toFixed(2))
          $total.find('input[name*="sum_003"]').val(tot_p03.toFixed(2))
          $total.find('input[name*="sum_016"]').val(tot_p16.toFixed(2))
          $total.find('input[name*="sum_out"]').val(tot_res.toFixed(2))
          return
        select: (slcts)->
          slcts.each ()->
            $select = $(this)
            $sd = $select.data()
            if $select.hasClass 'select2'
              $select.select2
                formatNoMatches: (term)->
                  Wstm.desk.expenditure.noMatchesMsg(term)
                ajax:
                  url: "/utils/search/#{$sd.model}"
                  dataType: 'json'
                  quietMillis: 1000
                  data: (term)->
                    q: term
                  results: (data)->
                    results: data
              $select.unbind()
              $select.on 'change', ()->
                $button = $('button.expenditure')
                $url = "/sys/wstm/expenditure/create?client_id=#{$select.select2('val')}"
                $button.on 'click', ()->
                  Trst.desk.closeDesk()
                  Trst.desk.init($url)
                  return
                $button.button 'option', 'disabled', false
                return
            else if $select.hasClass 'freight'
              $select.on 'change', ()->
                $sod = $select.find('option:selected').data()
                $inp = $select.parentsUntil('tbody').last().find('input')
                $inp.filter('[name*="freight_id"]').val($select.val())
                $inp.filter('[name*="id_date"]').val($('#date_send').val())
                $inp.filter('[name*="id_stats"]').val($sod.id_stats)
                $inp.filter('[name*="um"]').val($sod.um)
                pu = $inp.filter('[name*="pu"]').val($sod.pu).decFixed(2)
                qu = $inp.filter('[name*="qu"]').val('0.00')
                pu.on 'change', ()->
                  Wstm.desk.expenditure.calculate()
                qu.on 'change', ()->
                  Wstm.desk.expenditure.calculate()
                Wstm.desk.expenditure.calculate()
                qu.focus().select()
            else
              $msg 'Select not handled!'
        buttons: (btns)->
          btns.each ()->
            $button = $(this)
            $bd = $button.data()
            if Trst.desk.hdo.dialog is 'filter'
              if $bd.action is 'create'
                $button.unbind()
                $button.button 'option', 'disabled', true
                return
            else if Trst.desk.hdo.dialog is 'create'
              if $bd.action is 'save'
                if Trst.desk.hdf.attr('action') is '/sys/wstm/expenditure'
                  $button.unbind()
                  $button.on 'click', ()->
                    Wstm.desk.expenditure.calculate()
                    $url  = Trst.desk.hdf.attr('action')
                    $type = Trst.desk.hdf.attr('method')
                    $data = Trst.desk.hdf.serializeArray()
                    $url += "/create"
                    Trst.desk.closeDesk(false)
                    Trst.desk.init($url,$type,$data)
                    $msg 'Wstm::Expenditure save...'
            else
              ###
              Buttons default handler Trst.desk.buttons
              ###
          $('span.row-remove').each ()->
            $button = $(this)
            $button.on 'click', ()->
              $button.parentsUntil('tbody').last().remove()
              Wstm.desk.expenditure.calculate()
              return
          return
        init: ()->
          Wstm.desk.expenditure.buttons($('button'))
          Wstm.desk.expenditure.select($('select.wstm, input.select2'))
          $msg 'Wstm.desk.expenditure.init() OK...'
  Wstm
