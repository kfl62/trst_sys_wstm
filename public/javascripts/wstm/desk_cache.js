(function() {
  define(function() {
    $.extend(true, Wstm, {
      desk: {
        cache: {
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
              if (Trst.desk.hdo.dialog === 'query') {
                $select.on('change', function() {
                  var $params, $url;
                  $params = jQuery.param($('.param').serializeArray());
                  $url = "sys/wstm/cache/query?" + $params;
                  Trst.desk.init($url);
                });
              }
            });
          },
          buttons: function(btns) {
            btns.each(function() {
              var $bd, $button;
              $button = $(this);
              $bd = $button.data();
              if (Trst.desk.hdo.dialog === 'query') {
                $button.on('click', function() {
                  var $params, $url;
                  $params = jQuery.param($('.param').serializeArray());
                  $url = "sys/wstm/cache/query?" + $params + "&uid=" + ($button.attr('id'));
                  Trst.desk.init($url);
                });
              }
            });
          },
          init: function() {
            this.buttons($('span.link'));
            this.selects($('select'));
            return $log('Wstm.desk.cache.init() OK...');
          }
        }
      }
    });
    return Wstm.desk.cache;
  });

}).call(this);
