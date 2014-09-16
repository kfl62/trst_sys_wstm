(function() {
  define(function() {
    $.extend(true, Wstm, {
      desk: {
        freight: {
          handleFreight: function() {
            $('select').each(function() {
              var $select;
              $select = $(this);
              $select.on('change', function() {
                var $params, $url;
                $params = jQuery.param($('.param').serializeArray());
                $url = "sys/wstm/freight/query?" + $params;
                Trst.desk.init($url);
              });
            });
          },
          handleNoFreight: function() {
            $('select').each(function() {
              var $select;
              $select = $(this);
              $select.on('change', function() {
                var $params, $url;
                $params = jQuery.param($('.param').serializeArray());
                $url = "sys/wstm/freight/query?" + $params;
                Trst.desk.init($url);
              });
            });
            if (Trst.desk.hdo.dialog === 'query') {
              $('span.link').each(function() {
                var $link;
                $link = $(this);
                $link.on('click', function() {
                  var $params, $url;
                  $params = jQuery.param($('.param').serializeArray());
                  $url = "sys/wstm/freight/query?" + $params;
                  $url += $link.hasClass('uid') ? "&uid=" + ($link.attr('id')) : "&fid=" + ($link.attr('id'));
                  Trst.desk.init($url);
                });
              });
            }
          },
          init: function() {
            var _ref;
            if ((_ref = Trst.desk.hdo.dialog) === 'query' || _ref === 'query_value') {
              if ($('#xhr_info').hasClass('noFreight')) {
                Wstm.desk.freight.handleNoFreight();
              }
              if ($('#xhr_info').hasClass('hasFreight')) {
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
