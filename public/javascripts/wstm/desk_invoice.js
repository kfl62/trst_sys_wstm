(function() {
  define(function() {
    $.extend(true, Wstm, {
      desk: {
        invoice: {
          calculate: function() {
            var $rows, $total, tot_vi;
            $rows = $('tr.freight');
            $total = $('tr.total');
            tot_vi = 0;
            $rows.each(function() {
              var $tr, pu, qu, val;
              $tr = $(this);
              pu = $tr.find('input[name*="pu"]').decFixed(4);
              qu = $tr.find('input[name*="qu"]').decFixed(2);
              val = (parseFloat(pu.val()) * parseFloat(qu.val())).round(2);
              tot_vi += val;
              return $tr.find('span.val_invoice').text(val.toFixed(2));
            });
            $total.find('span.sum_100').text(tot_vi.toFixed(2));
            $total.find('input[name*="sum_100"]').val(tot_vi.toFixed(2));
            if (tot_vi > 0) {
              $('button[data-action="save"]').button('option', 'disabled', false);
            } else {
              $('button[data-action="save"]').button('option', 'disabled', true);
            }
          },
          validate: {
            filter: function() {
              var $url;
              if (Trst.desk.hdo.title_data != null) {
                if ($('#supplr_id').val() !== '' && $('#supplr_d_id').val() !== '' && $('#supplr_d_id').val() !== 'new' && $('select.p03').val() !== 'null') {
                  $url = Trst.desk.hdf.attr('action');
                  $url += "/filter?grn_ary=true&y=" + ($('select.y').val());
                  $url += "&m=" + ($('select.m').val());
                  $url += "&p03=" + ($('select.p03').val());
                  $url += "&supplr_id=" + ($('#supplr_id').val());
                  Wstm.desk.tmp.clear('supplr').set('supplr', $('#supplr_id').select2('data'));
                  Wstm.desk.tmp.clear('supplr_d').set('supplr_d', $('#supplr_d_id').select2('data'));
                  Trst.desk.init($url);
                } else {
                  $('.grns').hide();
                }
              } else {
                if ($('#client_id').val() !== '' && $('#client_d_id').val() !== '' && $('#client_d_id').val() !== 'new' && $('select.p03').val() !== 'null') {
                  $url = Trst.desk.hdf.attr('action');
                  $url += "/filter?dln_ary=true&y=" + ($('select.y').val());
                  $url += "&m=" + ($('select.m').val());
                  $url += "&p03=" + ($('select.p03').val());
                  $url += "&client_id=" + ($('#client_id').val());
                  Wstm.desk.tmp.clear('client').set('client', $('#client_id').select2('data'));
                  Wstm.desk.tmp.clear('client_d').set('client_d', $('#client_d_id').select2('data'));
                  Trst.desk.init($url);
                } else {
                  $('.dlns').hide();
                }
              }
            }
          },
          selectedGrns: function() {
            var $url;
            this.grn_ary = [];
            $('input:checked').each(function() {
              Wstm.desk.invoice.grn_ary.push(this.id);
            });
            $url = Trst.desk.hdf.attr('action');
            $url += "/filter?y=" + ($('select.y').val());
            $url += "&m=" + ($('select.m').val());
            $url += "&p03=" + ($('select.p03').val());
            $url += "&supplr_id=" + ($('#supplr_id').val());
            if (Wstm.desk.invoice.grn_ary.length) {
              $url += "&grn_ary=" + Wstm.desk.invoice.grn_ary;
            }
            Wstm.desk.tmp.clear('supplr').set('supplr', $('#supplr_id').select2('data'));
            Wstm.desk.tmp.clear('supplr_d').set('supplr_d', $('#supplr_d_id').select2('data'));
            Trst.desk.init($url);
          },
          selectedDeliveryNotes: function() {
            var $url;
            this.dln_ary = [];
            $('input:checked').each(function() {
              Wstm.desk.invoice.dln_ary.push(this.id);
            });
            $url = Trst.desk.hdf.attr('action');
            $url += "/filter?y=" + ($('select.y').val());
            $url += "&m=" + ($('select.m').val());
            $url += "&p03=" + ($('select.p03').val());
            $url += "&client_id=" + ($('#client_id').val());
            if (Wstm.desk.invoice.dln_ary.length) {
              $url += "&dln_ary=" + Wstm.desk.invoice.dln_ary;
            }
            Wstm.desk.tmp.clear('client').set('client', $('#client_id').select2('data'));
            Wstm.desk.tmp.clear('client_d').set('client_d', $('#client_d_id').select2('data'));
            Trst.desk.init($url);
          },
          inputs: function(inpts) {
            inpts.each(function() {
              var $id, $input, _ref, _ref1;
              $input = $(this);
              $id = $input.attr('id');
              if ($input.hasClass('dln_ary')) {
                $input.on('change', function() {
                  Wstm.desk.invoice.selectedDeliveryNotes();
                });
              }
              if ($input.hasClass('grn_ary')) {
                $input.on('change', function() {
                  Wstm.desk.invoice.selectedGrns();
                });
              }
              if (((_ref = $input.attr('name')) != null ? _ref.match(/([^\[^\]]+)/g).pop() : void 0) === 'doc_name') {
                if (Trst.desk.hdo.title_data != null) {
                  $input.on('change', function() {
                    inpts.filter('[name*="\[name\]"]:not([type="hidden"])').val($(this).val());
                    return $('button[data-action="save"]').button('option', 'disabled', false);
                  });
                  return;
                } else {
                  $input.on('change', function() {
                    if (inpts.filter('[name*="pu\]"]:not([type="hidden"])').length) {
                      inpts.filter('[name*="pu\]"]:not([type="hidden"])').first().focus();
                    } else {
                      $('button[data-action="save"]').button('option', 'disabled', false);
                    }
                  });
                }
              }
              if (((_ref1 = $input.attr('name')) != null ? _ref1.match(/([^\[^\]]+)/g).pop() : void 0) === 'pu') {
                return $input.on('change', function() {
                  Wstm.desk.invoice.calculate();
                });
              }
            });
          },
          selects: function(slcts) {
            slcts.each(function() {
              var $dlg, $dlgph, $dlgsd, $id, $ph, $sd, $select;
              $select = $(this);
              $sd = $select.data();
              $id = $select.attr('id');
              if ($select.hasClass('wstm')) {
                if ($select.hasClass('p03')) {
                  $select.on('change', function() {
                    if ($select.val() === 'null') {
                      slcts.filter('#client_id,#supplr_id').select2('data', null).select2('enable', false).next().select2('data', null).select2('destroy');
                      slcts.filter('#client_id,#supplr_id').next().next().hide();
                    } else {
                      slcts.filter('#client_id,#supplr_id').select2('enable', true);
                    }
                    Wstm.desk.invoice.validate.filter();
                  });
                } else {

                  /*
                  Just for params no special treatment
                   */
                }
              } else if ($select.hasClass('select2')) {
                if ($id === 'client_id') {
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
                  if (slcts.filter('.p03').val() === 'null') {
                    $select.select2('enable', false);
                  }
                  if (Wstm.desk.tmp.client) {
                    $select.select2('data', Wstm.desk.tmp.client);
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
                    $dlg.select2('data', Wstm.desk.tmp.client_d);
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
                      return Wstm.desk.invoice.validate.filter();
                    });
                  }
                  $select.unbind();
                  $select.on('change', function() {
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
                        return Wstm.desk.invoice.validate.filter();
                      });
                    } else {
                      $select.next().select2('data', null);
                      $select.next().select2('destroy');
                      $select.next().next().hide();
                    }
                    return Wstm.desk.invoice.validate.filter();
                  });
                }
                if ($id === 'supplr_id') {
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
                  if (slcts.filter('.p03').val() === 'null') {
                    $select.select2('enable', false);
                  }
                  if (Wstm.desk.tmp.supplr) {
                    $select.select2('data', Wstm.desk.tmp.supplr);
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
                    $dlg.select2('data', Wstm.desk.tmp.supplr_d);
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
                      return Wstm.desk.invoice.validate.filter();
                    });
                  }
                  $select.unbind();
                  $select.on('change', function() {
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
                        return Wstm.desk.invoice.validate.filter();
                      });
                    } else {
                      $select.next().select2('data', null);
                      $select.next().select2('destroy');
                      $select.next().next().hide();
                    }
                    return Wstm.desk.invoice.validate.filter();
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
              var $bd, $button, $id, $url, _ref, _ref1;
              $button = $(this);
              $bd = $button.data();
              $id = $button.attr('id');
              if (Trst.desk.hdo.dialog === 'filter') {
                if ($id === 'client_d' || $id === 'supplr_d') {
                  $button.hide();
                }
                if ($bd.action === 'create') {
                  if ($('input:checked').length === 0) {
                    if ($button.hasClass('inv')) {
                      return $button.button('option', 'disabled', true);
                    }
                  } else {
                    $bd = $button.data();
                    $url = Trst.desk.hdf.attr('action');
                    $url += "/create?y=" + ($('select.y').val());
                    $url += "&m=" + ($('select.m').val());
                    $url += "&p03=" + ($('select.p03').val());
                    if ((_ref = Wstm.desk.invoice.dln_ary) != null ? _ref.length : void 0) {
                      $url += "&client_id=" + Wstm.desk.tmp.client.id;
                      $url += "&client_d_id=" + Wstm.desk.tmp.client_d.id;
                      $url += "&dln_ary=" + Wstm.desk.invoice.dln_ary;
                    }
                    if ((_ref1 = Wstm.desk.invoice.grn_ary) != null ? _ref1.length : void 0) {
                      $url += "&supplr_id=" + Wstm.desk.tmp.supplr.id;
                      $url += "&supplr_d_id=" + Wstm.desk.tmp.supplr_d.id;
                      $url += "&grn_ary=" + Wstm.desk.invoice.grn_ary;
                    }
                    $bd.url = $url;
                    return $button.button('option', 'disabled', false);
                  }
                }
              } else if (Trst.desk.hdo.dialog === 'create') {
                if ($bd.action === 'save') {
                  $button.button('option', 'disabled', true);
                  return $button.data('remove', false);
                }
              } else if (Trst.desk.hdo.dialog === 'show') {
                if ($bd.action === 'print') {
                  $button.on('click', function() {
                    Trst.msgShow(Trst.i18n.msg.report.start);
                    $.fileDownload("/sys/wstm/invoice/print?id=" + Trst.desk.hdo.oid, {
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
              } else if (Trst.desk.hdo.dialog === 'repair') {
                return $button.focus();
              } else {

                /*
                Buttons default handler Trst.desk.buttons
                 */
              }
            });
            $('span.icon-remove-sign').each(function() {
              var $button;
              $button = $(this);
              return $button.on('click', function() {
                $button.parentsUntil('tbody').last().remove();
                Wstm.desk.invoice.calculate();
              });
            });
          },
          init: function() {
            var min, now;
            if ($('#client_id,#supplr_id').val() === '' && $('#client_d_id,#supplr_d_id').val() === '' && $('select.p03').val() === 'null') {
              Wstm.desk.tmp.clear();
              delete this.grn_ary;
              delete this.dln_ary;
            }
            if ($('#date_show').length) {
              now = new Date();
              min = Trst.lst.admin === 'true' ? new Date(now.getFullYear(), now.getMonth() - 1, 1) : min = new Date(now.getFullYear(), now.getMonth(), 1);
              $('#date_show').datepicker('option', 'maxDate', '+0');
              $('#date_show').datepicker('option', 'minDate', min);
            }
            Wstm.desk.invoice.buttons($('button'));
            Wstm.desk.invoice.selects($('select.wstm,input.select2,input.repair'));
            Wstm.desk.invoice.inputs($('input'));
            return $log('Wstm.desk.invoice.init() OK...');
          }
        }
      }
    });
    return Wstm.desk.invoice;
  });

}).call(this);
