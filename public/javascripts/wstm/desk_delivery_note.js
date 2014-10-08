(function() {
  define(function() {
    $.extend(true, Wstm, {
      desk: {
        delivery_note: {
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
            $('span[data-val=nro').text("" + next + ".");
            $('input[data-mark~=related-add]').val('');
            $('select[data-mark~=related-add]').val('null');
          },
          lineNewData: function() {
            var $fd, $freight, freight_id, ord, pu_invoice, qu, stck, um, v;
            v = $('[data-mark~=related-add]');
            $freight = v.filter('[data-val=freight]');
            $fd = $freight.find('option:selected').data();
            ord = $('tr[data-mark~=related]').not('.hidden').length + 1;
            freight_id = $freight.val();
            um = $fd.um;
            v.filter('[data-val=um]').val(um);
            stck = $fd.stck;
            stck = ($.isNumeric(stck) ? parseFloat(stck).toFixed(2) : '0.00');
            v.filter('[data-val=stck]').val(stck);
            qu = v.filter('input[data-val=qu]').val();
            qu = $.isNumeric(qu) ? parseFloat(qu).toFixed(2) : '0.00';
            pu_invoice = v.filter('input[data-val=pu_invoice]').val();
            pu_invoice = $.isNumeric(pu_invoice) ? parseFloat(pu_invoice).toFixed(4) : '0.0000';
            return $.extend(true, $fd, {
              ord: ord,
              freight_id: freight_id,
              id_date: $('#date_send').val(),
              qu: qu,
              pu_invoice: pu_invoice
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
            var i, r, tot_qu, vl, vt;
            r = this.lineNewData();
            vl = $('tr[data-mark~=related]').not('.hidden');
            vt = $('tr[data-mark~=related-total]');
            i = 1;
            tot_qu = 0;
            vl.each(function() {
              var $row, qu, res, stck;
              $row = $(this);
              $row.find('input').each(function() {
                $(this).attr('name', $(this).attr('name').replace(/\d/, i));
              });
              stck = parseFloat($row.find('span[data-val=stck]').text());
              qu = parseFloat($row.find('input[data-val=qu]').val());
              res = (stck - qu).round(2);
              if (Wstm.desk.delivery_note.validate.stock(stck, qu)) {
                qu = stck;
                res = 0;
                $row.find('span[data-val=qu]').text(qu).decFixed(2);
                $row.find('input[data-val=qu]').val(qu).decFixed(2);
              }
              $row.find('span[data-val=ord]').text("" + i + ".");
              $row.find('input[data-val=val]').val(qu * parseFloat(r.pu)).decFixed(2);
              $row.find('input[data-val=val_invoice]').val(qu * parseFloat(r.pu_invoice)).decFixed(2);
              $row.find('[data-val=res]').text(res.toFixed(2));
              tot_qu += qu;
              i += 1;
            });
            vt.find('[data-val=tot-qu]').text(tot_qu.toFixed(2));
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
                if ($('span[data-val=nro]').text() !== '1.') {
                  $('button[data-action="save"]').button('option', 'disabled', false);
                }
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
                    return $('input[name*="id_date"]').each(function() {
                      $(this).val($('#date_send').val());
                    });
                  }
                });
                return;
              }
              if ($input.data().mark === 'wpu') {
                return $input.on('change', function() {
                  var $url;
                  Trst.msgShow();
                  if ($input.is(':checked')) {
                    $url = "/sys/partial/wstm/delivery_note/_doc_add_line?wpu=" + ($input.val());
                    $('td.add-line-container').load($url, function() {
                      Wstm.desk.delivery_note.buttons($('span.button'));
                      Wstm.desk.delivery_note.inputs($('input[data-mark=wpu]'));
                      Wstm.desk.delivery_note.selects($('select[data-val=freight]'));
                      Trst.desk.inputs.handleUI();
                      Trst.msgHide();
                    });
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
              if ($sd.mark === 's2') {
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
              }
              if ($sd.val === 'freight') {
                $select.on('change', function() {
                  if (Wstm.desk.delivery_note.validate.create()) {
                    Wstm.desk.delivery_note.lineNewData();
                    $('input[data-val=qu]').focus().select();
                  } else {
                    $select.val('null');
                  }
                });
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
                    $button.button('option', 'disabled', true);
                  }
                }
              }
              if (Trst.desk.hdo.dialog === 'create') {
                if ($bd.action === 'save') {
                  $button.button('option', 'disabled', true);
                }
              }
              if ($button.hasClass('fa-refresh')) {
                $button.off('click');
                $button.on('click', function() {
                  Wstm.desk.delivery_note.lineNewReset();
                });
              }
              if ($button.hasClass('fa-plus-circle')) {
                $button.off('click');
                $button.on('click', function() {
                  Wstm.desk.delivery_note.lineInsert();
                });
              }
              if ($button.hasClass('fa-minus-circle')) {
                $button.off('click');
                $button.on('click', function() {
                  $button.parentsUntil('tbody').last().remove();
                  Wstm.desk.delivery_note.calculate();
                  Wstm.desk.delivery_note.lineNewReset();
                });
              }
            });
          },
          init: function() {
            var _ref;
            this.buttons($('button,span.button'));
            this.selects($('input[data-mark~=s2],input[data-mark~=repair],select'));
            this.inputs($('input'));
            this.template = (_ref = $('tr.template')) != null ? _ref.remove() : void 0;
            this.lineNewReset();
            return $log('Wstm.desk.delivery_note.init() OK...');
          }
        }
      }
    });
    return Wstm.desk.delivery_note;
  });

}).call(this);
