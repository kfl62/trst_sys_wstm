(function() {

  define(function() {
    $.extend(true, Wstm, {
      desk: {
        freight: {
          handleFreight: function() {
            var $sf, $sm, $sy;
            $sy = $('#y');
            $sm = $('#m');
            $sf = $('#f');
            $('select').each(function() {
              var $select;
              $select = $(this);
              $select.on('change', function() {
                var $url;
                $url = "sys/wstm/freight/query?y=" + ($sy.val()) + "&m=" + ($sm.val()) + "&uid=" + ($sf.data('uid')) + "&fid=" + ($sf.val());
                Trst.desk.init($url);
              });
            });
          },
          handleNoFreight: function() {
            var $sd, $sm, $su, $sy;
            $sy = $('#y');
            $sm = $('#m');
            $sd = $('#d');
            $su = $('#u');
            $('select').each(function() {
              var $select;
              $select = $(this);
              $select.on('change', function() {
                var $url;
                $url = "sys/wstm/freight/query?y=" + ($sy.val()) + "&m=" + ($sm.val()) + "&d=" + ($sd.val());
                if ($su.length) {
                  $url += "" + $url + "&uid=" + ($su.val());
                }
                Trst.desk.init($url);
              });
            });
            if (Trst.desk.hdo.dialog === 'query') {
              $('span.link').each(function() {
                var $link;
                $link = $(this);
                $link.on('click', function() {
                  var $url;
                  $url = "sys/wstm/freight/query?y=" + ($sy.val()) + "&m=" + ($sm.val());
                  if ($su.length) {
                    $url += "" + $url + "&uid=" + ($su.val()) + "&fid=" + ($link.attr('id'));
                  } else {
                    $url += $link.hasClass('uid') ? "" + $url + "&uid=" + ($link.attr('id')) : "" + $url + "&fid=" + ($link.attr('id'));
                  }
                  Trst.desk.init($url);
                });
              });
            }
          },
          init: function() {
            var _ref;
            if ((_ref = Trst.desk.hdo.dialog) === 'query' || _ref === 'query_value') {
              if ($('p.noFreight').length) {
                Wstm.desk.freight.handleNoFreight();
              }
              if ($('p.hasFreight').length) {
                Wstm.desk.freight.handleFreight();
              }
            }
            return $log('Wstm.desk.freight.init() OK...');
          }
        }
      }
    });
    return Wstm.desk.freight;
  });

}).call(this);
