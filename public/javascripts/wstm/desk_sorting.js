(function() {
  define(function() {
    $.extend(true, Wstm, {
      desk: {
        sorting: {
          calculate: function(fromFreight) {
            var $rows, $total, tot_qu, total_qu;

            if (fromFreight == null) {
              fromFreight = false;
            }
            $rows = $('tr.resl-freight');
            $total = $('tr.total');
            tot_qu = 0;
            if (fromFreight === true) {
              $('select.resl-freight').val('null');
              $('select.resl-freight').change();
              total_qu = 0;
            } else {
              $rows.each(function() {
                var $sd, $tr, qu;

                $tr = $(this);
                $sd = $tr.find('select').find('option:selected').data();
                qu = parseFloat($tr.find('input[name*="qu"]').decFixed(2).val());
                tot_qu += qu;
                $('#from-freight-qu').text(tot_qu.toFixed(2));
                return $('#from-freight-qu-submit').val(tot_qu.toFixed(2));
              });
            }
            $('#from-freight-stock').text(($('select.from-freight').find('option:selected').data().stck - parseFloat($('#from-freight-qu-submit').decFixed(2).val())).toFixed(2));
            $total.find('span.res').text(tot_qu.toFixed(2));
            if (tot_qu > 0) {
              $('button[data-action="save"]').button('option', 'disabled', false);
            } else {
              $('button[data-action="save"]').button('option', 'disabled', true);
            }
          },
          selects: function(slcts) {
            slcts.each(function() {
              var $sd, $select;

              $select = $(this);
              $sd = $select.data();
              if ($select.hasClass('resl-freight')) {
                $select.on('change', function() {
                  var $inp, $sod, qu;

                  $sod = $select.find('option:selected').data();
                  $inp = $select.parentsUntil('tbody').last().find('input');
                  $inp.filter('[name*="freight_id"]').val($select.val());
                  $inp.filter('[name*="id_date"]').val($('#date_send').val());
                  $inp.filter('[name*="id_stats"]').val($sod.id_stats);
                  $inp.filter('[name*="um"]').val($sod.um);
                  $inp.filter('[name*="pu"]').val(parseFloat($('select.from-freight').find('option:selected').data().pu).toFixed(2));
                  qu = $inp.filter('[name*="qu"]').val('0.00');
                  qu.on('change', function() {
                    return Wstm.desk.sorting.calculate();
                  });
                  Wstm.desk.sorting.calculate();
                  qu.focus().select();
                });
              } else if ($select.hasClass('from-freight')) {
                $select.on('change', function() {
                  var $inp, $sod;

                  $sod = $select.find('option:selected').data();
                  $inp = $select.parentsUntil('thead').next('tr').find('input');
                  $inp.filter('[name*="freight_id"]').val($select.val());
                  $inp.filter('[name*="id_date"]').val($('#date_send').val());
                  $inp.filter('[name*="id_stats"]').val($sod.id_stats);
                  $inp.filter('[name*="um"]').val($sod.um);
                  $inp.filter('[name*="qu"]').val('0.00');
                  $inp.filter('[name*="pu"]').val(parseFloat($sod.pu).toFixed(2));
                  $('#from-freight-stock').text(parseFloat($sod.stck).toFixed(2));
                  if ($select.val() === 'null') {
                    $('tbody').addClass('hidden');
                  } else {
                    $('tbody').removeClass('hidden');
                  }
                  Wstm.desk.sorting.calculate(true);
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
                    return Wstm.desk.sorting.selects($('input.repair'));
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
              if (Trst.desk.hdo.dialog === 'create') {
                if ($bd.action === 'save') {
                  $button.button('option', 'disabled', true);
                  $button.data('remove', false);
                  $button.off('click', Trst.desk.buttons.action.save);
                  $button.on('click', Wstm.desk.sorting.calculate);
                  return $button.on('click', Trst.desk.buttons.action.save);
                }
              } else if (Trst.desk.hdo.dialog === 'show') {
                if ($bd.action === 'print') {
                  return $button.on('click', function() {
                    Trst.msgShow(Trst.i18n.msg.report.start);
                    $.fileDownload("/sys/wstm/sorting/print?id=" + Trst.desk.hdo.oid, {
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
            $('span.icon-remove-sign').each(function() {
              var $button;

              $button = $(this);
              $button.on('click', function() {
                $button.parentsUntil('tbody').last().remove();
                Wstm.desk.sorting.calculate();
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
            Wstm.desk.sorting.buttons($('button'));
            Wstm.desk.sorting.selects($('select.wstm'));
            Wstm.desk.sorting.inputs($('input'));
            return $log('Wstm.desk.sorting.init() OK...');
          }
        }
      }
    });
    return Wstm.desk.sorting;
  });

}).call(this);
