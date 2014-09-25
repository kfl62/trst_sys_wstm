(function() {
  define(function() {
    $.extend(true, Wstm, {
      desk: {
        cache_book: {
          linesNewReset: function() {
            var next;
            next = $('tr[data-mark~=line]').not('.hidden').length + 1;
            if (next === 1) {
              $('tr[data-mark~=line-header], tr[data-mark~=line-total]').addClass('hidden');
              $('button[data-action=save]').button('option', 'disabled', true);
            } else {
              $('tr[data-mark~=line-header], tr[data-mark~=line-total]').removeClass('hidden');
              $('button[data-action=save]').button('option', 'disabled', false);
            }
            $('span[data-val=nr').text(next - 1);
            $('span[data-mark~=line-add]').text(next + '.');
            $('input[data-mark~=line-add]').val('');
            $('input[data-mark~=line-add][data-val=doc]').focus();
          },
          linesNewData: function() {
            var doc, exp, ins, ord, out, v;
            v = $('[data-mark=line-add]');
            ord = $('tr[data-mark~=line]').not('.hidden').length + 1;
            doc = v.filter('[data-val=doc]').val();
            exp = v.filter('[data-val=exp]').val();
            ins = v.filter('[data-val=ins]').val();
            if (ins === '') {
              ins = 0;
            } else {
              ins = parseFloat(ins);
            }
            out = v.filter('[data-val=out]').val();
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
                ins: ins.toFixed(2),
                out: out.toFixed(2)
              }
            };
          },
          linesInsert: function() {
            var l, r;
            r = Wstm.desk.cache_book.linesNewData().result;
            l = Wstm.desk.cache_book.template.clone().removeClass('template');
            l.find('span,input').each(function() {
              var e;
              e = $(this);
              if (e.data('val')) {
                if (e.is('span')) {
                  e.text(r[e.data('val')]);
                }
                if (e.is('input')) {
                  return e.val(r[e.data('val')]);
                }
              }
            });
            $('tr[data-mark~=line-total]').before(l);
            Wstm.desk.cache_book.calculate();
            Wstm.desk.cache_book.linesNewReset();
            Wstm.desk.cache_book.buttons($('span.button'));
          },
          calculate: function() {
            var $fb, i, ib, r, vl, vt, vtins, vtout;
            r = Wstm.desk.cache_book.linesNewData().result;
            vl = $('tr[data-mark~=line]').not('.hidden');
            vt = $('tr[data-mark~=line-total]');
            ib = parseFloat($('input[data-val=ib]').val());
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
                if ($input.data('val') === 'ord') {
                  $input.val(i);
                }
                if ($input.data('val') === 'ins') {
                  vtins += parseFloat($input.val());
                }
                if ($input.data('val') === 'out') {
                  return vtout += parseFloat($input.val());
                }
              });
              $row.find('span[data-val=ord]').text(i + '.');
              return i += 1;
            });
            vt.find('span[data-val=tot-ins]').text(vtins.toFixed(2));
            vt.find('span[data-val=tot-out]').text(vtout.toFixed(2));
            $fb = ib + vtins - vtout;
            $('input[data-val=fb]').val($fb);
            $('span[data-val=fb]').text($fb.toFixed(2));
            if (r.ord > 25 && $('#scroll-container').length === 0) {
              Wstm.desk.scrollHeader('table[data-mark~=scroll]', 380);
            }
            if (r.ord < 26 && $('#scroll-container').length === 1) {
              Wstm.desk.scrollHeader('table[data-mark~=scroll]', 0);
            }
          },
          inputs: function(inpts) {
            inpts.each(function() {
              var $ind, $input, _ref;
              $input = $(this);
              $ind = $input.data();
              if ($input.data('mark') === 'line-add') {
                $input.on('keyup', function() {
                  if ($input.val() !== '') {
                    $('button[data-action=save]').button('option', 'disabled', true);
                  }
                });
                if ((_ref = $input.data('val')) === 'ins' || _ref === 'out') {
                  $input.on('keypress', function(e) {
                    if (e.which === 13) {
                      return Wstm.desk.cache_book.linesInsert();
                    }
                  });
                }
              }
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
                  $params = jQuery.param($('[data-mark~=param]').serializeArray());
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
                      $url = "sys/wstm/cache_book/" + $bd.oid;
                    }
                    $.ajax({
                      type: 'POST',
                      url: '/sys/session/r_path/sys!wstm!cache_book!filter',
                      async: false
                    });
                    Trst.lst.setItem('r_path', 'sys/wstm/cache_book/filter');
                    Trst.desk.init($url);
                  });
                }
              } else if ($button.hasClass('fa-plus-circle')) {
                $button.off('click');
                $button.on('click', function() {
                  Wstm.desk.cache_book.linesInsert();
                });
              } else if ($button.hasClass('fa-refresh')) {
                $button.off('click');
                $button.on('click', function() {
                  Wstm.desk.cache_book.linesNewReset();
                });
              } else if ($button.hasClass('fa-minus-circle')) {
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
                    if ($tr.find('input[data-val=_id]').length) {
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
              } else if (Trst.desk.hdo.dialog === 'show') {
                if ($bd.action === 'print') {
                  $button.on('click', function() {
                    Trst.msgShow(Trst.i18n.msg.report.start);
                    $.fileDownload("/sys/wstm/cache_book/print?id=" + Trst.desk.hdo.oid, {
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
              }
            });
          },
          init: function() {
            var _ref;
            this.buttons($('button, span.link, span.button'));
            this.selects($('select[data-mark~=param], input.select2, input.repair'));
            this.inputs($('input'));
            this.template = (_ref = $('tr.template')) != null ? _ref.remove() : void 0;
            this.linesNewReset();
            $log('Wstm.desk.cache_book.init() OK...');
          }
        }
      }
    });
    return Wstm.desk.cache_book;
  });

}).call(this);
