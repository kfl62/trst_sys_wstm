(function() {
  define(function() {
    $.extend(true, Wstm, {
      desk: {
        cache_book: {
          linesNewReset: function() {
            var next;
            next = $('tr.lines').not('.hidden').length + 1;
            if (next === 1) {
              $('tr.lines-header, tr.lines-total').addClass('hidden');
            } else {
              $('tr.lines-header, tr.lines-total').removeClass('hidden');
            }
            $('span.lines').text(next - 1);
            $('span.add-line').text(next + '.');
            $('input.add-line').val('');
          },
          linesNewData: function() {
            var doc, exp, ins, ord, out, v;
            v = $('.add-line');
            ord = $('tr.lines').not('.hidden').length + 1;
            doc = v.filter('.doc').val();
            exp = v.filter('.exp').val();
            ins = v.filter('.ins').val();
            if (ins === '') {
              ins = 0;
            } else {
              ins = parseFloat(ins);
            }
            out = v.filter('.out').val();
            if (out === '') {
              out = 0;
            } else {
              out = parseFloat(out);
            }
            return {
              result: {
                ord: ord,
                doc: doc,
                exp: exp,
                ins: ins,
                out: out
              }
            };
          },
          linesInsert: function() {
            var l, r;
            r = Wstm.desk.cache_book.linesNewData().result;
            l = Wstm.desk.cache_book.template.clone().removeClass('template');
            l.find('span.ord').text(r.ord + '.');
            l.find('input.ord').val(r.ord);
            l.find('span.doc').text(r.doc);
            l.find('input.doc').val(r.doc);
            l.find('span.exp').text(r.exp);
            l.find('input.exp').val(r.exp);
            l.find('span.ins').text(r.ins.toFixed(2));
            l.find('input.ins').val(r.ins);
            l.find('span.out').text(r.out.toFixed(2));
            l.find('input.out').val(r.out);
            $('tr.lines-total').before(l);
            Wstm.desk.cache_book.calculate();
            Wstm.desk.cache_book.linesNewReset();
            Wstm.desk.cache_book.buttons($('span.button'));
          },
          calculate: function() {
            var $fb, i, ib, r, vl, vt, vtins, vtout;
            r = Wstm.desk.cache_book.linesNewData().result;
            vl = $('tr.lines').not('.hidden');
            vt = $('tr.lines-total');
            ib = parseFloat($('input.ib').val());
            i = 1;
            vtins = 0;
            vtout = 0;
            vl.each(function() {
              var $row;
              $row = $(this);
              $row.find('input').each(function() {
                var $input;
                $input = $(this);
                $input.attr('name', $input.attr('name').replace(/\d/, i));
                if ($input.hasClass('ord')) {
                  $input.val(i);
                }
                if ($input.hasClass('ins')) {
                  vtins += parseFloat($input.val());
                }
                if ($input.hasClass('out')) {
                  return vtout += parseFloat($input.val());
                }
              });
              $row.find('span.ord').text(i + '.');
              return i += 1;
            });
            vt.find('span.tot-in').text(vtins.toFixed(2));
            vt.find('span.tot-out').text(vtout.toFixed(2));
            $fb = ib + vtins - vtout;
            $('input.fb').val($fb);
            $('span.fb').text($fb.toFixed(2));
            if (r.ord > 25 && $('#scroll-container').length === 0) {
              Wstm.desk.scrollHeader('table.scroll', 380);
            }
            if (r.ord < 26 && $('#scroll-container').length === 1) {
              Wstm.desk.scrollHeader('table.scroll', 0);
            }
          },
          inputs: function(inpts) {
            inpts.each(function() {
              var $ind, $input;
              $input = $(this);
              $ind = $input.data();
            });
          },
          selects: function(slcts) {
            slcts.each(function() {
              var $sd, $select;
              $select = $(this);
              $sd = $select.data();
              if (Trst.desk.hdo.dialog === 'filter') {
                $select.on('change', function() {
                  var $params, $url;
                  $params = jQuery.param($('.param').serializeArray());
                  $url = "sys/wstm/cache_book/filter?" + $params;
                  Trst.desk.init($url);
                });
              }
            });
          },
          buttons: function(btns) {
            btns.each(function() {
              var $bd, $button, $tr;
              $button = $(this);
              $bd = $button.data();
              if ($button.hasClass('link')) {
                if (Trst.desk.hdo.dialog === 'filter') {
                  $button.on('click', function() {
                    var $url;
                    if ($bd.oid === 'nil') {
                      $url = "sys/wstm/cache_book/create?id_date=" + $bd.id_date;
                    } else {
                      $url = "sys/wstm/cache_book/edit/" + $bd.oid;
                    }
                    Trst.desk.init($url);
                  });
                }
              } else if ($button.hasClass('icon-plus-sign')) {
                $button.off('click');
                $button.on('click', function() {
                  Wstm.desk.cache_book.linesInsert();
                });
              } else if ($button.hasClass('icon-refresh')) {
                $button.off('click');
                $button.on('click', function() {
                  Wstm.desk.cache_book.calculate();
                });
              } else if ($button.hasClass('icon-minus-sign')) {
                $tr = $button.parentsUntil('tbody').last();
                $button.off('click');
                $button.on('click', function() {
                  var $nested;
                  if (Trst.desk.hdo.dialog === 'create') {
                    $tr.remove();
                    Wstm.desk.cache_book.calculate();
                    Wstm.desk.cache_book.linesNewReset();
                  }
                  if (Trst.desk.hdo.dialog === 'edit') {
                    if ($tr.find('input._id').length) {
                      $tr.addClass('hidden');
                      $nested = $tr.find('input').last().clone();
                      $nested.attr('name', $nested.attr('name').replace('out', '_destroy'));
                      $nested.val(1);
                      $tr.find('input').last().after($nested);
                      $tr.find('input').each(function() {
                        var $input;
                        $input = $(this);
                        return $input.attr('name', $input.attr('name').replace(/(\d)/, '_$1'));
                      });
                    } else {
                      $tr.remove();
                    }
                    Wstm.desk.cache_book.calculate();
                    Wstm.desk.cache_book.linesNewReset();
                  }
                });
              }
            });
          },
          init: function() {
            var _ref;
            Wstm.desk.cache_book.buttons($('button, span.link, span.button'));
            Wstm.desk.cache_book.selects($('select.param, input.select2, input.repair'));
            Wstm.desk.cache_book.inputs($('input'));
            Wstm.desk.cache_book.template = (_ref = $('tr.template')) != null ? _ref.remove() : void 0;
            $log('Wstm.desk.cache_book.init() OK...');
          }
        }
      }
    });
    return Wstm.desk.cache_book;
  });

}).call(this);
