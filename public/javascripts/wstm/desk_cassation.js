(function() {
  define(function() {
    $.extend(true, Wstm, {
      desk: {
        cassation: {
          calculate: function() {
            var $rows, $total, tot_qu;
            $rows = $('tr.freight');
            $total = $('tr.total');
            tot_qu = 0;
            $rows.each(function() {
              var $sd, $tr, qu, res, stck;
              $tr = $(this);
              $sd = $tr.find('select').find('option:selected').data();
              stck = parseFloat($tr.find('span.stck').text());
              qu = parseFloat($tr.find('input[name*="qu"]').decFixed(2).val());
              res = (stck - qu).round(2);
              if (res < 0) {
                alert(Trst.i18n.msg.cassation_negative_stock).replace('%{stck}', stck.toFixed(2)).replace('%{res}', (0 - res).toFixed(2));
                qu = stck;
                res = 0;
                $tr.find('input[name*="qu"]').val(qu).decFixed(2);
              }
              tot_qu += qu;
              $tr.find('span.res').text(res.toFixed(2));
            });
            $total.find('span.res').text(tot_qu.toFixed(2));
            if (tot_qu > 0) {
              $('button[data-action="save"]').button('option', 'disabled', false);
            } else {
              $('button[data-action="save"]').button('option', 'disabled', true);
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
                    return Wstm.desk.cassation.selects($('input.repair'));
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
              if ($select.hasClass('freight')) {
                $select.on('change', function() {
                  var $inp, $sod, $stck, qu;
                  $sod = $select.find('option:selected').data();
                  $inp = $select.parentsUntil('tbody').last().find('input');
                  $stck = $select.parentsUntil('tbody').last().find('span.stck');
                  $inp.filter('[name*="freight_id"]').val($select.val());
                  $inp.filter('[name*="id_date"]').val($('#date_send').val());
                  $inp.filter('[name*="id_stats"]').val($sod.id_stats);
                  $inp.filter('[name*="um"]').val($sod.um);
                  $inp.filter('[name*="pu"]').val(parseFloat($sod.pu).toFixed(2));
                  $stck.text(parseFloat($sod.stck).toFixed(2));
                  qu = $inp.filter('[name*="qu"]').val('0.00');
                  qu.on('change', function() {
                    return Wstm.desk.cassation.calculate();
                  });
                  Wstm.desk.cassation.calculate();
                  qu.focus().select();
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
              if (Trst.desk.hdo.dialog === 'create') {
                if ($bd.action === 'save') {
                  $button.button('option', 'disabled', true);
                  $button.data('remove', false);
                  $button.off('click', Trst.desk.buttons.action.save);
                  $button.on('click', Wstm.desk.cassation.calculate);
                  return $button.on('click', Trst.desk.buttons.action.save);
                }
              } else if (Trst.desk.hdo.dialog === 'show') {
                if ($bd.action === 'print') {
                  return $button.on('click', function() {
                    Trst.msgShow(Trst.i18n.msg.report.start);
                    $.fileDownload("/sys/wstm/cassation/print?id=" + Trst.desk.hdo.oid, {
                      successCallback: function() {
                        return Trst.msgHide();
                      },
                      failCallback: function() {
                        Trst.msgHide();
                        return Trst.desk.downloadError(Trst.desk.hdo.model_name);
                      }
                    });
                    return false;
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
              $button.on('click', function() {
                $button.parentsUntil('tbody').last().remove();
                Wstm.desk.cassation.calculate();
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
            Wstm.desk.cassation.buttons($('button'));
            Wstm.desk.cassation.selects($('select.wstm'));
            Wstm.desk.cassation.inputs($('input'));
            return $log('Wstm.desk.cassation.init() OK...');
          }
        }
      }
    });
    return Wstm.desk.cassation;
  });

}).call(this);
