(function() {
  define(function() {
    $.extend(true, Wstm, {
      desk: {
        grn: {
          lineNewReset: function() {
            var next;
            next = $('tr[data-mark~=related]').not('.hidden').length + 1;
            if (next === 1) {
              $('tr[data-mark~=related-header], tr[data-mark~=related-total]').addClass('hidden');
              $('button[data-action=save]').button('option', 'disabled', true);
            } else {
              $('tr[data-mark~=related-header], tr[data-mark~=related-total]').removeClass('hidden');
              $('button[data-action=save]').button('option', 'disabled', false);
            }
            $('span[data-val=nro').text(next + ".");
            $('input[data-mark~=related-add]').val('');
            $('select[data-mark~=related-add]').val('null');
          },
          lineNewData: function() {
            var $fd, $freight, _03, _16, freight_id, ord, out, pu, qu, um, v, val;
            v = $('[data-mark~=related-add]');
            $freight = v.filter('[data-val=freight]');
            $fd = $freight.find('option:selected').data();
            ord = $('tr[data-mark~=related]').not('.hidden').length + 1;
            freight_id = $freight.val();
            um = $fd.um;
            v.filter('[data-val=um]').val(um);
            pu = v.filter('input[data-val=pu]').val();
            pu = $.isNumeric(pu) ? parseFloat(pu).toFixed(4) : parseFloat($fd.pu).toFixed(4);
            v.filter('input[data-val=pu]').val(pu);
            qu = v.filter('input[data-val=qu]').val();
            qu = $.isNumeric(qu) ? parseFloat(qu).toFixed(2) : '0.00';
            val = (parseFloat(qu) * parseFloat(pu)).toFixed(2);
            _03 = $fd.p03 && $('#supplr_id').data('p03') ? (parseFloat(val) * 0.03).toFixed(2) : '0.00';
            _16 = (parseFloat(val) * 0.0).toFixed(2);
            out = (parseFloat(val) - parseFloat(_03) - parseFloat(_16)).toFixed(2);
            return $.extend(true, $fd, {
              ord: ord,
              freight_id: freight_id,
              id_date: $('#date_send').val(),
              qu: qu,
              pu: pu,
              val: val,
              _03: _03,
              _16: _16,
              out: out
            });
          },
          lineInsert: function() {
            var l, r;
            r = this.lineNewData();
            l = this.template.clone().removeClass('template');
            l.find('span,input').each(function() {
              var e;
              e = $(this);
              if (e.data('val')) {
                if (e.is('span')) {
                  e.text(r[e.data('val')]);
                }
                if (e.is('input') && e.val() === '') {
                  return e.val(r[e.data('val')]);
                }
              }
            });
            if (parseFloat(r.qu) > 0) {
              $('tr[data-mark~=related-total]').before(l);
            }
            this.calculate();
            this.lineNewReset();
            this.buttons($('span.button'));
          },
          calculate: function() {
            var i, sum_003, sum_016, sum_100, sum_out, vl, vt;
            vl = $('tr[data-mark~=related]').not('.hidden');
            vt = $('tr[data-mark~=related-total]');
            i = 1;
            sum_100 = 0;
            sum_003 = 0;
            sum_016 = 0;
            sum_out = 0;
            vl.each(function() {
              var $row, _03, _16, out, val;
              $row = $(this);
              $row.find('span[data-val=ord]').text(i + ".");
              $row.find('input').each(function() {
                $(this).attr('name', $(this).attr('name').replace(/\d/, i));
              });
              val = parseFloat($row.find('span[data-val=val]').text());
              _03 = parseFloat($row.find('span[data-val=_03]').text());
              _16 = parseFloat($row.find('span[data-val=_16]').text());
              out = parseFloat($row.find('span[data-val=out]').text());
              sum_100 += val;
              sum_003 += _03;
              sum_016 += _16;
              sum_out += out;
              i += 1;
            });
            vt.find('span[data-val=sum-100]').text(sum_100.toFixed(2));
            vt.find('span[data-val=sum-003]').text(sum_003.toFixed(2));
            vt.find('span[data-val=sum-016]').text(sum_016.toFixed(2));
            vt.find('span[data-val=sum-out]').text(sum_out.toFixed(2));
            vt.find('input[data-val=sum-100]').val(sum_100.toFixed(2));
            vt.find('input[data-val=sum-003]').val(sum_003.toFixed(2));
            vt.find('input[data-val=sum-016]').val(sum_016.toFixed(2));
            vt.find('input[data-val=sum-out]').val(sum_out.toFixed(2));
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
                $('button[data-action="create"]').last().data('url', $url);
                $('button[data-action="create"]').last().button('option', 'disabled', false);
              } else {
                $('button[data-action="create"]').last().button('option', 'disabled', true);
              }
            },
            create: function() {
              var $transp_d;
              $('input[data-mark~=related-add][data-val=pu]').val($('select[data-mark~=related-add][data-val=freight] option:selected').data('pu'));
              $('input[data-mark~=related-add][data-val=qu]').val('0.00');
              if ($('span[data-val=nro]').text() !== '1.') {
                $('button[data-action="save"]').button('option', 'disabled', false);
              }
              true;
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
                  $('span.fa-plus-circle').show();
                  return true;
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
            $url += "&p03=" + ($('select').val());
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
              if ($sd.mark === 'p03') {
                $select.on('change', function() {
                  var $url;
                  $url = Trst.desk.hdf.attr('action');
                  if ($select.val() !== 'null') {
                    $url += "&p03=" + ($select.val());
                  }
                  Trst.desk.init($url);
                });
              }
              if ($select.data().mark === 's2') {
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
                        $dlgadd.data('url', '/sys/wstm/partner_firm/person');
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
              }
              if ($sd.mark === 'repair') {
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
                    $markup += "<span class='dsp-ib'>Doc: </span>";
                    $markup += "<span class='w-8rem dsp-ib'>" + d.text.doc_name + "</span>";
                    $markup += "<span class='dsp-ib'> - Firma: </span>";
                    $markup += "<span class='w-20rem dsp-ib'>" + d.text.supplier + "</span>";
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
              }
              if ($sd.val === 'freight') {
                return $select.on('change', function() {
                  if (Wstm.desk.grn.validate.create()) {
                    Wstm.desk.grn.lineNewData();
                    $('input[data-mark~=related-add][data-val=qu]').focus().select();
                  } else {
                    $select.val('null');
                  }
                });
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
                    if ($id === void 0) {
                      $button.button('option', 'disabled', true);
                    }
                  } else {
                    $bd = $button.data();
                    $url = '/sys/wstm/grn/create?id_intern=true';
                    $url += "&unit_id=" + Trst.desk.hdo.unit_id;
                    $url += "&dln_ary=" + Wstm.desk.grn.dln_ary;
                    $bd.url = $url;
                    $button.button('option', 'disabled', false);
                  }
                }
              }
              if (Trst.desk.hdo.dialog === 'show') {
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
                  return;
                }
              }
              if ($button.hasClass('fa-refresh')) {
                $button.off('click');
                $button.on('click', function() {
                  Wstm.desk.grn.lineNewReset();
                });
              }
              if ($button.hasClass('fa-plus-circle')) {
                $button.off('click');
                $button.on('click', function() {
                  Wstm.desk.grn.lineInsert();
                });
              }
              if ($button.hasClass('fa-minus-circle')) {
                $button.off('click');
                $button.on('click', function() {
                  $button.parentsUntil('tbody').last().remove();
                  Wstm.desk.grn.calculate();
                  Wstm.desk.grn.lineNewReset();
                });
              }
            });
          },
          init: function() {
            var ref;
            this.buttons($('button,span.button'));
            this.selects($('input[data-mark~=s2],input[data-mark~=repair],select'));
            this.inputs($('input'));
            this.template = (ref = $('tr.template')) != null ? ref.remove() : void 0;
            this.lineNewReset();
            return $log('Wstm.desk.grn.init() OK...');
          }
        }
      }
    });
    return Wstm.desk.grn;
  });

}).call(this);
