(function() {
  define(function() {
    $.extend(true, Wstm, {
      desk: {
        expenditure: {
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
            var $fd, $freight, freight_id, ord, out, pu, qu, um, v, val, _03, _16;
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
            _03 = $fd.p03 ? (parseFloat(val) * 0.03).toFixed(2) : '0.00';
            _16 = (parseFloat(val) * 0.16).toFixed(2);
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
          validate: {
            create: function() {
              $('input[data-mark~=related-add][data-val=pu]').val($('select[data-mark~=related-add][data-val=freight] option:selected').data('pu'));
              $('input[data-mark~=related-add][data-val=qu]').val('0.00');
              if ($('span[data-val=nro]').text() !== '1.') {
                $('button[data-action="save"]').button('option', 'disabled', false);
              }
              return true;
            }
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
              var $row, out, val, _03, _16;
              $row = $(this);
              $row.find('span[data-val=ord]').text("" + i + ".");
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
          noMatchesMsg: function(term) {
            var $button, $msg;
            $button = $('button#client');
            if (term.length < 13) {
              $button.button('option', 'disabled', true);
              return $msg = Trst.i18n.msg.id_pn.start.replace('%{data}', 13 - term.length);
            } else if (term.length === 13) {
              if (Trst.desk.inputs.__f.validateIdPN(term)) {
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
          selects: function(slcts) {
            slcts.each(function() {
              var $ph, $sd, $select;
              $select = $(this);
              $sd = $select.data();
              if ($sd.mark === 's2') {
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
                $select.on('change', function() {
                  var $button;
                  $button = $('button[data-action=create]:not(#client)');
                  $button.data('url', "/sys/wstm/expenditure?client_id=" + ($select.select2('val')));
                  $button.button('option', 'disabled', false);
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
                  if (Wstm.desk.expenditure.validate.create()) {
                    Wstm.desk.expenditure.lineNewData();
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
              var $bd, $button;
              $button = $(this);
              $bd = $button.data();
              if (Trst.desk.hdo.dialog === 'filter') {
                if ($bd.action === 'create') {
                  $button.button('option', 'disabled', true);
                }
              }
              if (Trst.desk.hdo.dialog === 'create') {
                if ($bd.action === 'save') {
                  if (Trst.desk.hdf.attr('action') === '/sys/wstm/expenditure') {
                    $button.data('remove', false);
                    $button.off('click', Trst.desk.buttons.action.save);
                    $button.on('click', Wstm.desk.expenditure.calculate);
                    $button.on('click', Trst.desk.buttons.action.save);
                    $log('Wstm::Expenditure save...');
                  }
                }
              }
              if ($button.hasClass('fa-refresh')) {
                $button.off('click');
                $button.on('click', function() {
                  Wstm.desk.expenditure.lineNewReset();
                });
              }
              if ($button.hasClass('fa-plus-circle')) {
                $button.off('click');
                $button.on('click', function() {
                  Wstm.desk.expenditure.lineInsert();
                });
              }
              if ($button.hasClass('fa-minus-circle')) {
                $button.off('click');
                $button.on('click', function() {
                  $button.parentsUntil('tbody').last().remove();
                  Wstm.desk.expenditure.calculate();
                  Wstm.desk.expenditure.lineNewReset();
                });
              }
            });
          },
          init: function() {
            var _ref;
            this.buttons($('button,span.button'));
            this.selects($('select, input[data-mark~=s2], input[data-mark~=repair]'));
            this.inputs($('input'));
            this.template = (_ref = $('tr.template')) != null ? _ref.remove() : void 0;
            this.lineNewReset();
            return $log('Wstm.desk.expenditure.init() OK...');
          }
        }
      }
    });
    return Wstm.desk.expenditure;
  });

}).call(this);
