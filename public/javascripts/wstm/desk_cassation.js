(function() {
  define(function() {
    $.extend(true, Wstm, {
      desk: {
        cassation: {
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
              if (Wstm.desk.cassation.validate.stock(stck, qu)) {
                qu = stck;
                res = 0;
                $row.find('span[data-val=qu]').text(qu).decFixed(2);
                $row.find('input[data-val=qu]').val(qu).decFixed(2);
              }
              $row.find('span[data-val=ord]').text("" + i + ".");
              $row.find('input[data-val=val]').val(qu * parseFloat($row.find('input[data-val=pu]').val())).decFixed(2);
              $row.find('input[data-val=val_invoice]').val(qu * parseFloat($row.find('input[data-val=pu_invoice]').val())).decFixed(2);
              $row.find('[data-val=res]').text(res.toFixed(2));
              tot_qu += qu;
              i += 1;
            });
            vt.find('[data-val=tot-qu]').text(tot_qu.toFixed(2));
          },
          validate: {
            stock: function(s, q) {
              if (s - q < 0) {
                alert(Trst.i18n.msg.cassation_negative_stock.replace('%{stck}', s.toFixed(2)).replace('%{res}', (q - s).toFixed(2)));
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
                });
                return;
              }
              if ($input.data().mark === 'wpu') {
                return $input.on('change', function() {
                  var $url;
                  Trst.msgShow();
                  if ($input.is(':checked')) {
                    $url = "/sys/partial/wstm/cassation/_doc_add_line?wpu=" + ($input.val());
                    $('td.add-line-container').load($url, function() {
                      Wstm.desk.cassation.buttons($('span.button'));
                      Wstm.desk.cassation.inputs($('input[data-mark=wpu]'));
                      Wstm.desk.cassation.selects($('select[data-val=freight]'));
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
              var $id, $sd, $select;
              $select = $(this);
              $sd = $select.data();
              $id = $select.attr('id');
              if ($select.data('val') === 'freight') {
                $select.on('change', function() {
                  if ($select.val() === 'null') {
                    Wstm.desk.cassation.lineNewReset();
                  } else {
                    Wstm.desk.cassation.lineNewData();
                    $('input[data-mark~=related-add][data-val=qu]').focus().select();
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
              if ($button.hasClass('fa-refresh')) {
                $button.off('click');
                $button.on('click', function() {
                  Wstm.desk.cassation.lineNewReset();
                });
              }
              if ($button.hasClass('fa-plus-circle')) {
                $button.off('click');
                $button.on('click', function() {
                  Wstm.desk.cassation.lineInsert();
                });
              }
              if ($button.hasClass('fa-minus-circle')) {
                $button.off('click');
                $button.on('click', function() {
                  $button.parentsUntil('tbody').last().remove();
                  Wstm.desk.cassation.calculate();
                  Wstm.desk.cassation.lineNewReset();
                });
              }
            });
          },
          init: function() {
            var _ref;
            this.buttons($('button, span.button'));
            this.selects($('select'));
            this.inputs($('input'));
            this.template = (_ref = $('tr.template')) != null ? _ref.remove() : void 0;
            this.lineNewReset();
            return $log('Wstm.desk.cassation.init() OK...');
          }
        }
      }
    });
    return Wstm.desk.cassation;
  });

}).call(this);
