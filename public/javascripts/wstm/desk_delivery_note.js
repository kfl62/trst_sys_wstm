(function() {
  define(function() {
    $.extend(true, Wstm, {
      desk: {
        delivery_note: {
          calculate: function() {
            var $rows, $total, tot_qu;
            $rows = $('tr.freight');
            $total = $('tr.total');
            tot_qu = 0;
            $rows.each(function() {
              var $sd, $tr, puf, pui, qu, res, stck, valf, vali;
              $tr = $(this);
              $sd = $tr.find('select').find('option:selected').data();
              stck = parseFloat($tr.find('span.stck').text());
              qu = parseFloat($tr.find('input[name*="qu"]').decFixed(2).val());
              puf = parseFloat($tr.find('input[name*="\[pu\]"]').decFixed(2).val());
              pui = parseFloat($tr.find('input[name*="\[pu_i"]').decFixed(4).val());
              res = (stck - qu).round(2);
              if (Wstm.desk.delivery_note.validate.stock(stck, qu)) {
                qu = stck;
                res = 0;
                $tr.find('input[name*="qu"]').val(qu).decFixed(2);
                if (Wstm.desk.tmp[$sd.key] === 0) {
                  $tr.find('select').val('null');
                  puf = 0;
                  $tr.find('input[name*="\[pu\]"]').val(0).decFixed(4);
                  $tr.find('select').focus();
                }
              }
              Wstm.desk.tmp[$sd.key] = res;
              if (puf >= 0) {
                valf = (puf * qu).round(2);
                vali = (pui * qu).round(2);
                $tr.find('input[name*="\[val\]"]').val(valf);
                $tr.find('input[name*="\[val_i"]').val(vali);
              }
              tot_qu += qu;
              return $tr.find('span.res').text(res.toFixed(2));
            });
            $total.find('span.res').text(tot_qu.toFixed(2));
          },
          validate: {
            filter: function() {
              var $url;
              if ($('#client_id').val() !== '' && $('#transporter_id').val() !== '' && $('#transp_d_id').val() !== '' && $('#transp_d_id').val() !== 'new') {
                $url = Trst.desk.hdf.attr('action');
                $url += "?client_id=" + ($('#client_id').val());
                $url += "&transp_id=" + ($('#transp_id').val());
                $url += "&transp_d_id=" + ($('#transp_d_id').val());
                if ($('#client_d_id').val() !== '' && $('#client_d_id').val() !== 'new') {
                  $url += "&client_d_id=" + ($('#client_d_id').val());
                }
                $('button[data-action="create"]').data('url', $url);
                $('button[data-action="create"]').button('option', 'disabled', false);
              } else {
                $('button[data-action="create"]').button('option', 'disabled', true);
              }
            },
            create: function() {
              if (/[A-Z]{3}-$/.test($('input[name*="doc_name"]').val()) || $('input[name*="doc_name"]').val() === '' || $('input[name*="doc_plat"]').val() === '') {
                alert(Trst.i18n.msg.delivery_note_not_complete);
                return false;
              } else {
                $('button[data-action="save"]').button('option', 'disabled', false);
                $('span.fa-plus-circle').show();
                return true;
              }
            },
            stock: function(s, q) {
              if (s - q < 0) {
                alert(Trst.i18n.msg.delivery_note_negative_stock.replace('%{stck}', s.toFixed(2)).replace('%{res}', (q - s).toFixed(2)));
                return true;
              }
            }
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
                    return Wstm.desk.delivery_note.selects($('input.repair'));
                  }
                });
              }
            });
          },
          selects: function(slcts) {
            slcts.each(function() {
              var $id, $ph, $sd, $select;
              $select = $(this);
              $sd = $select.data();
              $id = $select.attr('id');
              if ($select.hasClass('select2')) {
                if ($id === 'client_id' || $id === 'transp_id') {
                  $ph = Trst.i18n.select[Trst.desk.hdo.js_ext][$sd.ph];
                  $select.select2({
                    placeholder: $ph,
                    minimumInputLength: $sd.minlength,
                    allowClear: true,
                    ajax: {
                      url: "/utils/search/" + $sd.search,
                      dataType: 'json',
                      quietMillis: 100,
                      data: function(term) {
                        return {
                          w: $id.split('_')[0],
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
                    var $dlg, $dlgph, $dlgsd;
                    if ($select.select2('data')) {
                      $select.next().select2('data', null);
                      $select.next().select2('destroy');
                      $dlg = $select.next();
                      $dlgsd = $dlg.data();
                      $dlgph = Trst.i18n.select[Trst.desk.hdo.js_ext][$dlgsd.ph];
                      $dlg.select2({
                        placeholder: $dlgph,
                        minimumInputLength: $dlgsd.minlength,
                        allowClear: true,
                        ajax: {
                          url: "/utils/search/" + $sd.search,
                          dataType: 'json',
                          data: function(term) {
                            return {
                              id: $select.select2('val')
                            };
                          },
                          results: function(data) {
                            return {
                              results: data
                            };
                          }
                        }
                      });
                      $dlg.unbind();
                      $dlg.on('change', function() {
                        var $dlgadd;
                        if ($dlg.select2('data')) {
                          if ($dlg.select2('data').id === 'new') {
                            $dlgadd = $dlg.next();
                            $dlgadd.data('url', '/sys/wstm/partner_firm/person');
                            $dlgadd.data('r_id', $select.select2('val'));
                            $dlgadd.data('r_mdl', 'firm');
                            $dlgadd.show();
                          } else {
                            $dlg.next().hide();
                          }
                        } else {
                          $dlg.next().hide();
                        }
                        return Wstm.desk.delivery_note.validate.filter();
                      });
                    } else {
                      $select.next().select2('data', null);
                      $select.next().select2('destroy');
                      $select.next().next().hide();
                    }
                    return Wstm.desk.delivery_note.validate.filter();
                  });
                }
              } else if ($select.hasClass('freight')) {
                return $select.on('change', function() {
                  var $inp, $puf, $sod, $stck, qu;
                  if (Wstm.desk.delivery_note.validate.create()) {
                    Wstm.desk.tmp.set('newRow', $('tr.freight').last());
                    $sod = $select.find('option:selected').data();
                    $inp = $select.parentsUntil('tbody').last().find('input');
                    $puf = $select.parentsUntil('tbody').last().find('span.val.puf');
                    $stck = $select.parentsUntil('tbody').last().find('span.stck');
                    $inp.filter('[name*="freight_id"]').val($select.val());
                    $inp.filter('[name*="id_date"]').val($('#date_send').val());
                    $inp.filter('[name*="id_stats"]').val($sod.id_stats);
                    $inp.filter('[name*="um"]').val($sod.um);
                    $inp.filter('[name*="\[pu\]"]').val($sod.pu);
                    $puf.text(parseFloat($sod.pu).toFixed(2));
                    $stck.text(parseFloat(Wstm.desk.tmp.set($sod.key, $sod.stck)).toFixed(2));
                    qu = $inp.filter('[name*="qu"]').val('0.00');
                    qu.on('change', function() {
                      return Wstm.desk.delivery_note.calculate();
                    });
                    Wstm.desk.delivery_note.calculate();
                    qu.focus().select();
                    return;
                  } else {
                    $select.val('null');
                  }
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
                    $markup += "<span class='repair'>Doc: </span>";
                    $markup += "<span class='truncate-70'>" + d.text.doc_name + "</span>";
                    $markup += "<span class='repair'> - Firma: </span>";
                    $markup += "<span class='truncate-200'>" + d.text.client + "</span>";
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
              var $bd, $button, $id;
              $button = $(this);
              $bd = $button.data();
              $id = $button.attr('id');
              if (Trst.desk.hdo.dialog === 'filter') {
                if ($id === 'client_d' || $id === 'transp_d') {
                  $button.hide();
                }
                if ($bd.action === 'create') {
                  if (!$id) {
                    return $button.button('option', 'disabled', true);
                  }
                }
              } else if (Trst.desk.hdo.dialog === 'create') {
                if ($bd.action === 'save') {
                  $button.button('option', 'disabled', true);
                  $button.data('remove', false);
                  $button.off('click', Trst.desk.buttons.action.save);
                  $button.on('click', Wstm.desk.delivery_note.calculate);
                  return $button.on('click', Trst.desk.buttons.action.save);
                }
              } else if (Trst.desk.hdo.dialog === 'show') {
                if ($bd.action === 'print') {
                  $button.on('click', function() {
                    Trst.msgShow(Trst.i18n.msg.report.start);
                    $.fileDownload("/sys/wstm/delivery_note/print?id=" + Trst.desk.hdo.oid, {
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
            $('tbody').on('click', 'span.fa-minus-circle', function() {
              var $button;
              $button = $(this);
              $button.parentsUntil('tbody').last().remove();
              Wstm.desk.delivery_note.calculate();
            });
            $('span.fa-plus-circle').on('click', function() {
              $('tr.total').before(Wstm.desk.tmp.newRow.clone());
              if (!$('#scroll-container').length) {
                if ($('table.scroll').height() > 320) {
                  Wstm.desk.scrollHeader($('table.scroll'), 308);
                }
              }
              $('tr.freight').last().find('input').each(function() {
                $(this).attr('name', $(this).attr('name').replace(/\d/, $('tr.freight').length - 1));
              });
              Wstm.desk.delivery_note.selects($('tr.freight').last().find('select'));
              Wstm.desk.delivery_note.calculate();
            });
            $('span.fa-plus-circle').hide();
          },
          init: function() {
            var min, now;
            Wstm.desk.tmp.clear();
            if ($('#date_show').length) {
              now = new Date();
              min = Trst.lst.admin === 'true' ? new Date(now.getFullYear(), now.getMonth() - 1, 1) : new Date(now.getFullYear(), now.getMonth(), 1);
              $('#date_show').datepicker('option', 'maxDate', '+0');
              $('#date_show').datepicker('option', 'minDate', min);
            }
            Wstm.desk.delivery_note.buttons($('button'));
            Wstm.desk.delivery_note.selects($('select.wstm,input.select2,input.repair'));
            Wstm.desk.delivery_note.inputs($('input'));
            return $log('Wstm.desk.delivery_note.init() OK...');
          }
        }
      }
    });
    return Wstm.desk.delivery_note;
  });

}).call(this);
