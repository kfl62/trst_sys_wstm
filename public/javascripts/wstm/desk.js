(function() {
  var __slice = [].slice,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  define(function() {
    $.extend(true, Wstm, {
      desk: {
        tmp: {
          set: function(key, value) {
            if (this[key] || this[key] === 0) {
              return this[key];
            } else {
              return this[key] = value;
            }
          },
          clear: function() {
            var what;
            what = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
            return $.each(this, (function(_this) {
              return function(k) {
                if (what.length) {
                  if (__indexOf.call(__slice.call(what), k) >= 0) {
                    return delete _this[k];
                  }
                } else {
                  if (k !== 'set' && k !== 'clear') {
                    return delete _this[k];
                  }
                }
              };
            })(this));
          }
        },
        scrollHeader: function(tbl, h) {
          var $table, tblClmnW, tblCntnr, tblHdr, tblscrll;
          if (h == null) {
            h = 450;
          }
          $table = $(tbl);
          if (h !== 0) {
            tblHdr = $("<table style='width:auto'><tbody class='inner'><tr></tr><tr></tr></tbody></table>");
            tblCntnr = $("<div id='scroll-container' style='height:" + h + "px;overflow-x:hidden;overflow-y:scroll'></div>");
            tblClmnW = [];
            $table.find('tr.scroll td').each(function(i) {
              tblClmnW[i] = $(this).width();
            });
            tblscrll = $table.find('tr.scroll').html();
            $table.find('tr.scroll').html('');
            $table.css('width', 'auto');
            tblHdr.find('tr:first').html(tblscrll);
            tblHdr.find('tr:first td').each(function(i) {
              $(this).css('width', tblClmnW[i]);
            });
            $table.find('tr.scroll').next().find('td').each(function(i) {
              $(this).css('width', tblClmnW[i]);
            });
            $table.before(tblHdr);
            $table.wrap(tblCntnr);
          } else {
            tblscrll = $('div#scroll-container').prev().find('tr:first').html();
            $('div#scroll-container').prev().remove();
            $table.find('tr.scroll').html(tblscrll);
            $table.unwrap();
          }
        },
        idPnHandle: function() {
          var $input;
          $input = $('input[name*="id_pn"]');
          if (Wstm.desk.idPnValidate($input.val())) {
            $input.attr('class', 'ui-state-default');
            $input.parents('tr').next().find('input').focus();
          } else {
            $input.attr('class', 'ui-state-error').focus();
          }
        },
        idPnValidate: function(id) {
          var $chk, $mod, $sum, i, _fn, _i;
          $chk = "279146358279";
          $sum = 0;
          _fn = function(i) {
            return $sum += id.charAt(i) * $chk.charAt(i);
          };
          for (i = _i = 0; _i <= 12; i = ++_i) {
            _fn(i);
          }
          $mod = $sum % 11;
          if (($mod < 10 && $mod.toString() === id.charAt(12)) || ($mod === 10 && id.charAt(12) === "1")) {
            return true;
          } else {
            return false;
          }
        },
        datePicker: function(node) {
          var $datepicker, max, min, now, _ref;
          $datepicker = $(node);
          now = new Date();
          min = Trst.lst.admin === 'true' ? new Date(now.getFullYear(), now.getMonth() - 1, 1) : new Date(now.getFullYear(), now.getMonth(), 1);
          max = Trst.lst.admin === 'true' ? '+1' : '+0';
          $datepicker.datepicker({
            altField: '#date_send',
            altFormat: 'yy-mm-dd',
            maxDate: max,
            minDate: min,
            regional: ['ro']
          });
          $datepicker.addClass('ta-ce').attr('size', ((_ref = $datepicker.val()) != null ? _ref.length : void 0) + 2);
          $datepicker.on('change', function() {
            var _ref1;
            $datepicker.attr('size', ((_ref1 = $datepicker.val()) != null ? _ref1.length : void 0) + 2);
          });
        },
        init: function() {
          var $ext, $id_intern;
          this.datePicker($('#date_show'));
          if ($('input.id_intern').length) {
            $id_intern = $('input[name*="\[name\]"]');
            $id_intern.attr('size', $id_intern.val().length + 4);
            $id_intern.on('change', function() {
              $id_intern.attr('size', $id_intern.val().length + 4);
            });
          }
          if (Trst.desk.hdo.dialog === 'create' || Trst.desk.hdo.dialog === 'edit') {
            if ($('input[name*="id_pn"]').length) {
              Wstm.desk.idPnHandle();
              $('input[name*="id_pn"]').on('keyup', function() {
                return Wstm.desk.idPnHandle();
              });
            }
            $('input.focus').focus();
            $('select.focus').focus();
          }
          if ($('table.scroll').height() > 450) {
            Wstm.desk.scrollHeader($('table.scroll'));
          }
          $log('Wstm.desk.init() Ok...');
          if ($('select.wstm, input.select2').length) {
            require(['wstm/desk_select'], function(select) {
              return select.init();
            });
          }
          if ($ext = Trst.desk.hdo.js_ext) {
            require(["wstm/" + $ext], function(ext) {
              return ext.init();
            });
          }
        }
      }
    });
    return Wstm.desk;
  });

}).call(this);
