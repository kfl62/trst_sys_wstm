(function() {

  define(function() {
    $.extend(true, Wstm, {
      desk: {
        stock: {
          template: function() {
            var $node, $pu, $qu, $sd, $sl, $tr, $vl, _ref;
            $tr = $('tr.plus');
            $sl = $tr.find(':selected');
            $sd = $sl.data();
            $pu = $tr.find('input.pu');
            $qu = $tr.find('input.quw');
            $vl = $tr.find('span.stats');
            $node = $('tr.freight').last().clone();
            if ($node.hasClass('hidden')) {
              if (!$('tr.freight').last().find('input[name*="_destroy"]').length) {
                $('tr.freight').last().remove();
              }
              $node.removeClass('hidden');
            }
            if ((_ref = Trst.desk.hdo.dialog) === 'create' || _ref === 'edit') {
              $node.find('span.stats').each(function(i) {
                if (i === 0) {
                  $(this).html($sl.text());
                }
                if (i === 1) {
                  $(this).html($sd.um);
                }
                if (i === 2) {
                  return $(this).html($vl.html());
                }
              });
              $node.find('input').each(function(i) {
                if (i === 0) {
                  $(this).val($sl.val()).prop('name', function(i, o) {
                    return o.replace(/\d/, $('tr.freight').length);
                  });
                }
                if (i === 1) {
                  $(this).val($sd.id_stats).prop('name', function(i, o) {
                    return o.replace(/\d/, $('tr.freight').length);
                  });
                }
                if (i === 2) {
                  $(this).val('false').prop('name', function(i, o) {
                    return o.replace(/\d/, $('tr.freight').length);
                  });
                }
                if (i === 3) {
                  $(this).val($('input[name*="id_date"]').val()).prop('name', function(i, o) {
                    return o.replace(/\d/, $('tr.freight').length);
                  });
                }
                if (i === 4) {
                  $(this).val($sd.um).prop('name', function(i, o) {
                    return o.replace(/\d/, $('tr.freight').length);
                  });
                }
                if (i === 5) {
                  $(this).val($pu.val()).prop('name', function(i, o) {
                    return o.replace(/\d/, $('tr.freight').length);
                  });
                }
                if (i === 6) {
                  $(this).val($qu.val()).prop('name', function(i, o) {
                    return o.replace(/\d/, $('tr.freight').length);
                  });
                }
                if (i === 7) {
                  $(this).val($vl.text()).prop('name', function(i, o) {
                    return o.replace(/\d/, $('tr.freight').length);
                  });
                }
                if (i > 7) {
                  return $(this).remove();
                }
              });
            }
            $tr.find('select').val('null').change();
            return $node;
          },
          calculate: function() {
            $('tr.freight').each(function() {
              var $tr, pu, qu, val;
              $tr = $(this);
              pu = parseFloat($tr.find('input[name*="pu"]').decFixed(2).val());
              qu = parseFloat($tr.find('input[name*="qu"]').decFixed(2).val());
              val = (pu * qu).round(2);
              $tr.find('span.stats').last().html(val.toFixed(2));
              $tr.find('input[name*="val"]').val(val.toFixed(2));
            });
          },
          inputs: function(inpts) {
            inpts.each(function() {
              var $input, _ref, _ref1;
              $input = $(this);
              if ((_ref = (_ref1 = $input.attr('name')) != null ? _ref1.match(/([^\[^\]]+)/g).pop() : void 0) === 'pu' || _ref === 'quw') {
                $input.on('change', function() {
                  return Wstm.desk.stock.calculate();
                });
              }
            });
          },
          selects: function(slcts) {
            slcts.each(function() {
              var $select, $tr;
              $select = $(this);
              $tr = $('tr.plus');
              $select.on('change', function() {
                var $sd;
                $sd = $select.find('option:selected').data();
                $tr.find('input.pu').attr('value', $sd.pu).decFixed(2);
                $tr.find('input.quw').attr('value', '0.00');
                $tr.find('span.stats').html('0.00');
              });
            });
          },
          buttons: function(btns) {
            btns.each(function() {
              var $bd, $button, _ref;
              $button = $(this);
              $bd = $button.data();
              if ((_ref = Trst.desk.hdo.dialog) === 'create' || _ref === 'edit') {
                if ($bd.action === 'save') {
                  $button.data('remove', false);
                  $button.off('click', Trst.desk.buttons.action.save);
                  $button.on('click', Wstm.desk.stock.calculate);
                  $button.on('click', Trst.desk.buttons.action.save);
                  return $log('Wstm::Stock save...');
                }
              }
            });
            $('span.icon-remove-sign').each(function() {
              var $button, $tr;
              $button = $(this);
              $button.unbind();
              $tr = $button.parentsUntil('tbody').last();
              if (Trst.desk.hdo.dialog === 'create') {
                $button.on('click', function() {
                  $tr.remove();
                });
              }
              if (Trst.desk.hdo.dialog === 'edit') {
                $button.on('click', function() {
                  var $destroy;
                  $destroy = $tr.find('input').last().clone();
                  $destroy.attr('name', $destroy.attr('name').replace('id', '_destroy'));
                  $destroy.val(1);
                  $tr.find('input').last().after($destroy);
                  $tr.addClass('hidden');
                });
              }
            });
            $('span.icon-plus-sign').each(function() {
              var $button, $tr;
              $button = $(this);
              $button.unbind();
              $tr = $button.parentsUntil('tbody').last();
              $tr.css('background-color', 'lightYellow');
              $button.on('click', function() {
                if ($tr.find('select').val() !== 'null') {
                  $tr.before(Wstm.desk.stock.template());
                  Wstm.desk.stock.calculate();
                  Wstm.desk.stock.buttons($('button'));
                }
              });
            });
          },
          init: function() {
            Wstm.desk.stock.buttons($('button'));
            Wstm.desk.stock.selects($('select.wstm'));
            Wstm.desk.stock.inputs($('input'));
            return $log('Wstm.desk.stock.init() OK...');
          }
        }
      }
    });
    return Wstm.desk.stock;
  });

}).call(this);
