(function() {
  var slice = [].slice,
    indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

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
            what = 1 <= arguments.length ? slice.call(arguments, 0) : [];
            return $.each(this, (function(_this) {
              return function(k) {
                if (what.length) {
                  if (indexOf.call(slice.call(what), k) >= 0) {
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
        init: function() {
          var $ext;
          $log('Wstm.desk.init() Ok...');
          if ($('select[data-mark~=wstm]').length) {
            require(['wstm/desk_selects'], function(selects) {
              return selects.init();
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
