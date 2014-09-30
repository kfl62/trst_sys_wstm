(function() {
  define(function() {
    $.extend(true, Wstm, {
      desk: {
        cache: {
          selects: function(slcts) {
            slcts.each(function() {
              var $sd, $select;
              $select = $(this);
              $sd = $select.data();
              if (Trst.desk.hdo.dialog === 'query') {
                $select.on('change', function() {
                  var $params, $url;
                  $params = jQuery.param($('[data-mark~=param]').serializeArray());
                  $url = "sys/wstm/cache/query?" + $params;
                  Trst.desk.init($url);
                });
              }
            });
          },
          buttons: function(btns) {
            btns.each(function() {
              var $bd, $button, _ref;
              $button = $(this);
              $bd = $button.data();
              if (Trst.desk.hdo.dialog === 'filter') {
                if ((_ref = $bd.action) === 'create' || _ref === 'show' || _ref === 'edit' || _ref === 'delete') {
                  $bd.r_path = 'sys/wstm/cache/filter';
                }
              }
              if (Trst.desk.hdo.dialog === 'query') {
                $button.on('click', function() {
                  var $params, $url;
                  $params = jQuery.param($('[data-mark~=param]').serializeArray());
                  $url = "sys/wstm/cache/query?" + $params + "&uid=" + ($button.attr('id'));
                  Trst.desk.init($url);
                });
              }
            });
          },
          init: function() {
            this.buttons($('button, span.link'));
            this.selects($('select'));
            return $log('Wstm.desk.cache.init() OK...');
          }
        }
      }
    });
    return Wstm.desk.cache;
  });

}).call(this);
