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
                $params = jQuery.param($('[data-mark~=param]').serializeArray());
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
                $params = jQuery.param($('[data-mark~=param]').serializeArray());
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
                  $params = jQuery.param($('[data-mark~=param]').serializeArray());
                  $url = "sys/wstm/freight/query?" + $params;
                  $url += $link.hasClass('uid') ? "&uid=" + ($link.attr('id')) : "&fid=" + ($link.attr('id'));
                  Trst.desk.init($url);
                });
              });
            }
          },
          buttons: function(btns) {
            btns.each(function() {
              var $bd, $button, _ref;
              $button = $(this);
              $bd = $button.data();
              if (Trst.desk.hdo.dialog === 'filter') {
                if ((_ref = $bd.action) === 'create' || _ref === 'show' || _ref === 'edit' || _ref === 'delete') {
                  return $bd.r_path = 'sys/wstm/freight/filter';
                }
              }
            });
          },
          init: function() {
            var _ref;
            this.buttons($('button'));
            if ((_ref = Trst.desk.hdo.dialog) === 'query' || _ref === 'query_value') {
              if ($('#xhr_info').hasClass('noFreight')) {
                this.handleNoFreight();
              }
              if ($('#xhr_info').hasClass('hasFreight')) {
                this.handleFreight();
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
