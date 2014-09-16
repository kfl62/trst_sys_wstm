(function() {
  define(function() {
    $.extend(true, Wstm, {
      desk: {
        expenditure: {
          noMatchesMsg: function(term) {
            var $button, $msg;
            $button = $('button.partner-person');
            if (term.length < 13) {
              $button.button('option', 'disabled', true);
              return $msg = Trst.i18n.msg.id_pn.start.replace('%{data}', 13 - term.length);
            } else if (term.length === 13) {
              if (Wstm.desk.idPnValidate(term)) {
                $button.button('option', 'disabled', false);
                $button.data('url', "/sys/wstm/partner_person?id_pn=" + term);
                return $msg = Trst.i18n.msg.id_pn.valid;
              } else {
                $button.button('option', 'disabled', true);
                return $msg = Trst.i18n.msg.id_pn.invalid;
              }
            } else {
              $button.button('option', 'disabled', true);
              return $msg = Trst.i18n.msg.id_pn.too_long;
            }
          },
          calculate: function() {
            var $rows, $total, tot_p03, tot_p16, tot_res, tot_val;
            $rows = $('tr.freight');
            $total = $('tr.total');
            tot_val = 0;
            tot_p03 = 0;
            tot_p16 = 0;
            tot_res = 0;
            $rows.each(function() {
              var $sd, $tr, p03, p16, pu, qu, res, val;
              $tr = $(this);
              $sd = $tr.find('select').find('option:selected').data();
              if ($sd.id_stats) {
                pu = $tr.find('input[name*="pu"]').decFixed(2);
                qu = $tr.find('input[name*="qu"]').decFixed(2);
                val = (parseFloat(pu.val()) * parseFloat(qu.val())).round(2);
                p03 = $sd.p03 ? (val * 0.03).round(2) : 0;
                p16 = (val * 0.16).round(2);
                res = (val - p03 - p16).round(2);
              } else {
                pu = qu = val = p03 = p16 = res = 0;
                $tr.find('input[name*="pu"]').val('0.00');
                $tr.find('input[name*="qu"]').val('0.00');
              }
              tot_val += val;
              tot_p03 += p03;
              tot_p16 += p16;
              tot_res += res;
              $tr.find('span.val').text(val.toFixed(2));
              $tr.find('span.p03').text(p03.toFixed(2));
              $tr.find('span.p16').text(p16.toFixed(2));
              $tr.find('span.res').text(res.toFixed(2));
              $tr.find('input[name*="val"]').val(val.toFixed(2));
            });
            $total.find('span.val').text(tot_val.toFixed(2));
            $total.find('span.p03').text(tot_p03.toFixed(2));
            $total.find('span.p16').text(tot_p16.toFixed(2));
            $total.find('span.res').text(tot_res.toFixed(2));
            $total.find('input[name*="sum_100"]').val(tot_val.toFixed(2));
            $total.find('input[name*="sum_003"]').val(tot_p03.toFixed(2));
            $total.find('input[name*="sum_016"]').val(tot_p16.toFixed(2));
            $total.find('input[name*="sum_out"]').val(tot_res.toFixed(2));
          },
          inputs: function(inpts) {
            inpts.each(function() {
              var $input;
              $input = $(this);
              if ($input.attr('id') === 'date_show') {
                $input.on('change', function() {
                  if (Trst.desk.hdo.dialog === 'create') {
                    $('input[name*="id_date"]').each(function() {
                      if ($(this).val() !== '') {
                        $(this).val($('#date_send').val());
                      }
                    });
                  }
                  if (Trst.desk.hdo.dialog === 'repair') {
                    return Wstm.desk.expenditure.selects($('input.repair'));
                  }
                });
              } else if ($input.hasClass('pu') || $input.hasClass('qu')) {
                $input.on('change', function() {
                  return Wstm.desk.expenditure.calculate();
                });
              }
            });
          },
          selects: function(slcts) {
            slcts.each(function() {
              var $ph, $sd, $select;
              $select = $(this);
              $sd = $select.data();
              if ($select.hasClass('select2')) {
                $ph = Trst.i18n.select[Trst.desk.hdo.js_ext][$sd.ph];
                $select.select2({
                  placeholder: $ph,
                  minimumInputLength: $sd.minlength,
                  formatNoMatches: function(term) {
                    return Wstm.desk.expenditure.noMatchesMsg(term);
                  },
                  ajax: {
                    url: "/utils/search/" + $sd.search,
                    dataType: 'json',
                    quietMillis: 1000,
                    data: function(term) {
                      return {
                        q: term
                      };
                    },
                    results: function(data) {
                      return {
                        results: data
                      };
                    }
                  }
                });
                $select.unbind();
                return $select.on('change', function() {
                  var $button;
                  $button = $('button[data-action="create"]');
                  $button.data('url', "/sys/wstm/expenditure?client_id=" + ($select.select2('val')));
                  $button.button('option', 'disabled', false);
                });
              } else if ($select.hasClass('repair')) {
                $ph = Trst.i18n.select[Trst.desk.hdo.js_ext][$sd.ph];
                $select.select2({
                  placeholder: $ph,
                  allowClear: true,
                  quietMillis: 1000,
                  ajax: {
                    url: "/utils/search/" + $sd.search,
                    dataType: 'json',
                    data: function(term) {
                      return {
                        uid: $sd.uid,
                        day: $('#date_send').val(),
                        q: term
                      };
                    },
                    results: function(data) {
                      return {
                        results: data
                      };
                    }
                  },
                  formatResult: function(d) {
                    var $markup;
                    $markup = "<div title='" + d.text.title + "'>";
                    $markup += "<span>" + d.text.name + " </span>";
                    $markup += "<span>- " + d.text.time + " - </span>";
                    $markup += "<span>Val:</span>";
                    $markup += "<span style='width:50px;text-align:right;display:inline-block'>" + d.text.val + "</span>";
                    $markup += "<span> - Cash:</span>";
                    $markup += "<span style='width:50px;text-align:right;display:inline-block'>" + d.text.out + "</span>";
                    $markup += "</div>";
                    return $markup;
                  },
                  formatSelection: function(d) {
                    return d.text.name;
                  },
                  formatSearching: function() {
                    return Trst.i18n.msg.searching;
                  },
                  formatNoMatches: function(t) {
                    return Trst.i18n.msg.no_matches;
                  }
                });
                $select.off();
                return $select.on('change', function() {
                  var $url;
                  if ($select.select2('val') !== '') {
                    $url = Trst.desk.hdf.attr('action');
                    $url += "/" + ($select.select2('val'));
                    Trst.desk.closeDesk(false);
                    Trst.desk.init($url);
                  }
                });
              } else if ($select.hasClass('freight')) {
                return $select.on('change', function() {
                  var $inp, $sod, pu, qu;
                  $sod = $select.find('option:selected').data();
                  $inp = $select.parentsUntil('tbody').last().find('input');
                  $inp.filter('[name*="freight_id"]').val($select.val());
                  $inp.filter('[name*="id_date"]').val($('#date_send').val());
                  $inp.filter('[name*="id_stats"]').val($sod.id_stats);
                  $inp.filter('[name*="um"]').val($sod.um);
                  pu = $inp.filter('[name*="pu"]').val($sod.pu).decFixed(2);
                  qu = $inp.filter('[name*="qu"]').val('0.00');
                  Wstm.desk.expenditure.calculate();
                  return qu.focus().select();
                });
              } else if ($select.hasClass('wstm')) {

                /*
                Handled by Wstm.desk.select
                 */
              } else {
                return $log('Select not handled!');
              }
            });
          },
          buttons: function(btns) {
            btns.each(function() {
              var $bd, $button;
              $button = $(this);
              $bd = $button.data();
              if (Trst.desk.hdo.dialog === 'filter') {
                if ($bd.action === 'create') {
                  return $button.button('option', 'disabled', true);
                }
              } else if (Trst.desk.hdo.dialog === 'create') {
                if ($bd.action === 'save') {
                  if (Trst.desk.hdf.attr('action') === '/sys/wstm/expenditure') {
                    $button.data('remove', false);
                    $button.off('click', Trst.desk.buttons.action.save);
                    $button.on('click', Wstm.desk.expenditure.calculate);
                    $button.on('click', Trst.desk.buttons.action.save);
                    return $log('Wstm::Expenditure save...');
                  }
                }
              } else if (Trst.desk.hdo.dialog === 'show') {
                if ($bd.action === 'print') {
                  $button.on('click', function() {
                    Trst.msgShow(Trst.i18n.msg.report.start);
                    $.fileDownload("/sys/wstm/expenditure/print?id=" + Trst.desk.hdo.oid, {
                      successCallback: function() {
                        return Trst.msgHide();
                      },
                      failCallback: function() {
                        Trst.msgHide();
                        return Trst.desk.downloadError(Trst.desk.hdo.model_name);
                      }
                    });
                  });
                }
              } else {

                /*
                Buttons default handler Trst.desk.buttons
                 */
              }
            });
            $('span.fa-minus-circle').each(function() {
              var $button;
              $button = $(this);
              return $button.on('click', function() {
                $button.parentsUntil('tbody').last().remove();
                Wstm.desk.expenditure.calculate();
              });
            });
          },
          init: function() {
            var min, now;
            if ($('#date_show').length) {
              now = new Date();
              min = Trst.lst.admin === 'true' ? new Date(now.getFullYear(), now.getMonth() - 1, 1) : new Date(now.getFullYear(), now.getMonth(), 1);
              $('#date_show').datepicker('option', 'maxDate', '+0');
              $('#date_show').datepicker('option', 'minDate', min);
            }
            Wstm.desk.expenditure.buttons($('button'));
            Wstm.desk.expenditure.selects($('select.wstm, input.select2, input.repair'));
            Wstm.desk.expenditure.inputs($('input'));
            return $log('Wstm.desk.expenditure.init() OK...');
          }
        }
      }
    });
    return Wstm.desk.expenditure;
  });

}).call(this);
