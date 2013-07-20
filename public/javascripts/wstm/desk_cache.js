(function() {

  define(function() {
    $.extend(true, Wstm, {
      desk: {
        cache: {
          init: function() {
            var $sm, $su, $sy, min, now;
            if ($('#date_show').length) {
              now = new Date();
              min = Trst.lst.admin === 'true' ? new Date(now.getFullYear(), now.getMonth() - 1, 1) : new Date(now.getFullYear(), now.getMonth(), 1);
              $('#date_show').datepicker('option', 'maxDate', Trst.lst.admin === 'true' ? '+1' : '+0');
              $('#date_show').datepicker('option', 'minDate', min);
            }
            if (Trst.desk.hdo.dialog === 'query') {
              $sy = $('#y');
              $sm = $('#m');
              $su = $('#u');
              $('select').each(function() {
                var $select;
                $select = $(this);
                $select.on('change', function() {
                  var $url;
                  $url = "sys/wstm/cache/query?y=" + ($sy.val()) + "&m=" + ($sm.val());
                  if ($su.length) {
                    $url += "&uid=" + ($su.val());
                  }
                  Trst.desk.init($url);
                });
              });
              $('span.link').each(function() {
                var $link;
                $link = $(this);
                $link.on('click', function() {
                  var $url;
                  $url = "sys/wstm/cache/query?y=" + ($sy.val()) + "&m=" + ($sm.val()) + "&uid=" + ($link.attr('id'));
                  Trst.desk.init($url);
                });
              });
            }
            return $log('Wstm.desk.cache.init() OK...');
          }
        }
      }
    });
    return Wstm.desk.cache;
  });

}).call(this);
