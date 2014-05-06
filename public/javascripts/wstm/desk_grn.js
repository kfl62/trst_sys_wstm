(function() {
  define(function() {
    $.extend(true, Wstm, {
      desk: {
        grn: {
          calculate: function() {
            var $rows, $total, tot_p03, tot_val;
            $rows = $('tr.freight');
            $total = $('tr.total');
            tot_val = 0;
            tot_p03 = 0;
            $rows.each(function() {
              var $sd, $tr, p03, pu, qu, val;
              $tr = $(this);
              $sd = $tr.find('select').find('option:selected').data();
              pu = $tr.find('input[name*="pu"]').decFixed(2);
              qu = $tr.find('input[name*="qu"]').decFixed(2);
              val = (parseFloat(pu.val()) * parseFloat(qu.val())).round(2);
              p03 = $sd.p03 && $('#supplr_id').data('p03') ? (val * 0.03).round(2) : 0;
              tot_val += val;
              tot_p03 += p03;
              $tr.find('span.val').text(val.toFixed(2));
              $tr.find('span.p03').text(p03.toFixed(2));
              $tr.find('input[name*="val"]').val(val.toFixed(2));
            });
            $total.find('span.val').text(tot_val.toFixed(2));
            $total.find('span.p03').text(tot_p03.toFixed(2));
            $total.find('input[name*="sum_100"]').val(tot_val.toFixed(2));
            $total.find('input[name*="sum_003"]').val(tot_p03.toFixed(2));
            $total.find('input[name*="sum_out"]').val((tot_val - tot_p03).toFixed(2));
          },
          validate: {
            filter: function() {
              var $url;
              if ($('#supplr_id').val() !== '' && $('#transporter_id').val() !== '' && $('#transp_d_id').val() !== '' && $('#transp_d_id').val() !== 'new') {
                $url = Trst.desk.hdf.attr('action');
                $url += "?supplr_id=" + ($('#supplr_id').val());
                $url += "&transp_id=" + ($('#transp_id').val());
                $url += "&transp_d_id=" + ($('#transp_d_id').val());
                if ($('#supplr_d_id').val() !== '' && $('#supplr_d_id').val() !== 'new') {
                  $url += "&supplr_d_id=" + ($('#supplr_d_id').val());
                }
                $('button.grn').data('url', $url);
                $('button.grn').button('option', 'disabled', false);
              } else {
                $('button.grn').button('option', 'disabled', true);
              }
            },
            create: function() {
              var $transp_d;
              if ($('input#transp_d_id').length) {
                $transp_d = $('input#transp_d_id');
                if ($transp_d.select2('val') === '' || $transp_d.select2('val') === 'new') {
                  $('button[data-action="save"]').button('option', 'disabled', true);
                } else {
                  $('button[data-action="save"]').button('option', 'disabled', false);
                }
              }
              if ($('select.doc_type').length) {
                if ($('select.doc_type').val() !== 'null' && $('input[name*="doc_name"]').val() !== '' && $('input[name*="doc_plat"]').val() !== '') {
                  $('button[data-action="save"]').button('option', 'disabled', false);
                  $('span.icon-plus-sign').show();
                  return true;
                }
              }
            },
            pyms: function() {
              var _ref;
              if (((_ref = $('select.doc_type')) != null ? _ref.val() : void 0) !== 'INV') {
                $('tr.inv').remove();
              } else {
                if ($('input[name*="\[pyms\]\[val\]"]').val() === '') {
                  $('tr.inv.pyms').remove();
                }
              }
            }
          },
          selectedDeliveryNotes: function() {
            var $url;
            this.dln_ary = [];
            $('input:checked').each(function() {
              Wstm.desk.grn.dln_ary.push(this.id);
            });
            $url = Trst.desk.hdf.attr('action');
            $url += "&p03=" + ($('select.p03').val());
            if (Wstm.desk.grn.dln_ary.length) {
              $url += "&dln_ary=" + Wstm.desk.grn.dln_ary;
            }
            Trst.desk.init($url);
          },
          inputs: function(inpts) {
            inpts.each(function() {
              var $id, $input;
              $input = $(this);
              $id = $input.attr('id');
              if ($input.hasClass('dln_ary')) {
                $input.on('change', function() {
                  Wstm.desk.grn.selectedDeliveryNotes();
                });
              }
              if ($input.attr('id') === 'date_show') {
                $input.on('change', function() {
                  if (Trst.desk.hdo.dialog === 'create') {
                    $('input[name*="doc_date"]').val($('#date_send').val());
                    $('input[name*="id_date"]').each(function() {
                      if ($(this).val() !== '') {
                        $(this).val($('#date_send').val());
                      }
                    });
                    $('select.doc_type').focus();
                  }
                  if (Trst.desk.hdo.dialog === 'repair') {
                    return Wstm.desk.grn.selects($('input.repair'));
                  }
                });
                return;
              }
            });
          },
          selects: function(slcts) {
            slcts.each(function() {
              var $id, $ph, $sd, $select;
              $select = $(this);
              $sd = $select.data();
              $id = $select.attr('id');
              if ($select.hasClass('wstm')) {
                if ($select.hasClass('p03')) {
                  $select.on('change', function() {
                    var $url;
                    $url = Trst.desk.hdf.attr('action');
                    if ($select.val() !== 'null') {
                      $url += "&p03=" + ($select.val());
                    }
                    Trst.desk.init($url);
                  });
                }
                if ($select.hasClass('doc_type')) {
                  $('tr.inv').hide();
                  $select.on('change', function() {
                    $('input[name*="doc_date"]').val($('#date_send').val());
                    if ($select.val() === 'INV') {
                      $('tr.dn').hide();
                      $('tr.inv').show();
                      $('input[name*="deadl"]').val($('#date_send').val());
                      $('input[name*="\[pyms\]\[id_date\]"]').val($('#date_send').val());
                    } else {
                      $('tr.dn').show();
                      $('tr.inv').hide();
                    }
                    $select.next().focus();
                  });
                }
                if ($select.hasClass('freight')) {
                  $select.on('change', function() {
                    var $inp, $sod, pu, qu;
                    if (Wstm.desk.grn.validate.create()) {
                      Wstm.desk.tmp.set('newRow', $('tr.freight').last());
                      $sod = $select.find('option:selected').data();
                      $inp = $select.parentsUntil('tbody').last().find('input');
                      $inp.filter('[name*="freight_id"]').val($select.val());
                      $inp.filter('[name*="id_date"]').val($('#date_send').val());
                      $inp.filter('[name*="id_stats"]').val($sod.id_stats);
                      $inp.filter('[name*="um"]').val($sod.um);
                      pu = $inp.filter('[name*="pu"]').val($sod.pu).decFixed(2);
                      qu = $inp.filter('[name*="qu"]').val('0.00');
                      pu.on('change', function() {
                        return Wstm.desk.grn.calculate();
                      });
                      qu.on('change', function() {
                        return Wstm.desk.grn.calculate();
                      });
                      Wstm.desk.grn.calculate();
                      qu.focus().select();
                    } else {
                      alert(Trst.i18n.msg.grn_not_complete);
                      $select.val('null');
                      $('button[data-action="save"]').button('option', 'disabled', true);
                    }
                  });
                }
              } else if ($select.hasClass('select2')) {
                if ($id === 'supplr_id' || $id === 'transp_id') {
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
                  $select.on('change', function() {
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
                            $dlgadd.data('url', '/sys/wstm/partner_firm_person');
                            $dlgadd.data('r_id', $select.select2('val'));
                            $dlgadd.data('r_mdl', 'firm');
                            $dlgadd.show();
                          } else {
                            $dlg.next().hide();
                          }
                        } else {
                          $dlg.next().hide();
                        }
                        return Wstm.desk.grn.validate.filter();
                      });
                    } else {
                      $select.next().select2('data', null);
                      $select.next().select2('destroy');
                      $select.next().next().hide();
                    }
                    return Wstm.desk.grn.validate.filter();
                  });
                }
                if ($id === 'transp_d_id' && Trst.desk.hdo.dialog === 'create') {
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
                          id: $sd.transp_id
                        };
                      },
                      results: function(data) {
                        return {
                          results: data
                        };
                      }
                    }
                  });
                  $select.on('change', function() {
                    var $dlgadd;
                    if ($select.select2('data')) {
                      if ($select.select2('data').id === 'new') {
                        $dlgadd = $select.nextAll('button');
                        $dlgadd.data('url', '/sys/wstm/partner_firm_person');
                        $dlgadd.data('r_id', $sd.transp_id);
                        $dlgadd.data('r_mdl', 'firm');
                        $dlgadd.show();
                      } else {
                        $select.nextAll('button').hide();
                        $select.next().addClass('ce st').focus();
                      }
                    } else {
                      $select.nextAll('button').hide();
                    }
                    Wstm.desk.grn.validate.create();
                  });
                }
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
                    $markup += "<span class='truncate-200'>" + d.text.supplier + "</span>";
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
                $select.on('change', function() {
                  var $url;
                  if ($select.select2('val') !== '') {
                    $url = Trst.desk.hdf.attr('action');
                    $url += "/" + ($select.select2('val'));
                    Trst.desk.closeDesk(false);
                    Trst.desk.init($url);
                  }
                });
              } else {
                $log('Select not handled!');
              }
            });
          },
          buttons: function(btns) {
            btns.each(function() {
              var $bd, $button, $id, $url;
              $button = $(this);
              $bd = $button.data();
              $id = $button.attr('id');
              if (Trst.desk.hdo.dialog === 'filter') {
                if ($id === 'supplr_d' || $id === 'transp_d') {
                  $button.hide();
                }
                if ($bd.action === 'create') {
                  if ($('input:checked').length === 0) {
                    if ($button.hasClass('grn')) {
                      return $button.button('option', 'disabled', true);
                    }
                  } else {
                    $bd = $button.data();
                    $url = '/sys/wstm/grn/create?id_intern=true';
                    $url += "&unit_id=" + Trst.desk.hdo.unit_id;
                    $url += "&dln_ary=" + Wstm.desk.grn.dln_ary;
                    $bd.url = $url;
                    return $button.button('option', 'disabled', false);
                  }
                }
              } else if (Trst.desk.hdo.dialog === 'create') {
                if ($id === 'transp_d') {
                  $button.hide();
                }
                if ($bd.action === 'save') {
                  $button.button('option', 'disabled', true);
                  $button.data('remove', false);
                  $button.off('click', Trst.desk.buttons.action.save);
                  $button.on('click', Wstm.desk.grn.calculate);
                  $button.on('click', Wstm.desk.grn.validate.pyms);
                  $button.on('click', Trst.desk.buttons.action.save);
                  return $log('Wstm::Grn save...');
                }
              } else if (Trst.desk.hdo.dialog === 'show') {
                if ($bd.action === 'print') {
                  $button.on('click', function() {
                    Trst.msgShow(Trst.i18n.msg.report.start);
                    $.fileDownload("/sys/wstm/grn/print?id=" + Trst.desk.hdo.oid, {
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
            $('tbody').on('click', 'span.icon-remove-sign', function() {
              var $button;
              $button = $(this);
              $button.parentsUntil('tbody').last().remove();
              Wstm.desk.grn.calculate();
            });
            $('span.icon-plus-sign').on('click', function() {
              $('tr.total').before(Wstm.desk.tmp.newRow.clone());
              $('tr.freight').last().find('input').each(function() {
                $(this).attr('name', $(this).attr('name').replace(/\d/, $('tr.freight').length - 1));
              });
              Wstm.desk.grn.selects($('tr.freight').last().find('select'));
              Wstm.desk.grn.calculate();
            });
            $('span.icon-plus-sign').hide();
          },
          init: function() {
            var min, now;
            if ($('#date_show').length) {
              now = new Date();
              min = Trst.lst.admin === 'true' ? new Date(now.getFullYear(), now.getMonth() - 1, 1) : min = new Date(now.getFullYear(), now.getMonth(), 1);
              $('#date_show').datepicker('option', 'maxDate', '+0');
              $('#date_show').datepicker('option', 'minDate', min);
            }
            Wstm.desk.grn.buttons($('button'));
            Wstm.desk.grn.selects($('select.wstm,input.select2,input.repair'));
            Wstm.desk.grn.inputs($('input'));
            return $log('Wstm.desk.grn.init() OK...');
          }
        }
      }
    });
    return Wstm.desk.grn;
  });

}).call(this);
