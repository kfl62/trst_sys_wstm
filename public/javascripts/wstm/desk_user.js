(function() {
  define(function() {
    $.extend(true, Wstm, {
      desk: {
        user: {
          selects: function(slcts) {
            slcts.each(function() {
              var $sd, $select;
              $select = $(this);
              $sd = $select.data();
              if ($select.hasClass('select2')) {
                $select.select2({
                  placeholder: 'Selectaţi min. un gestionar...',
                  minimumInputLength: 0,
                  multiple: true,
                  data: $sd.data
                });
                $select.on('change', function() {
                  if ($select.select2('val').length) {
                    $('.query').button('option', 'disabled', false);
                  } else {
                    $('.query').button('option', 'disabled', true);
                  }
                });
              }
            });
          },
          buttons: function(btns) {
            btns.each(function() {
              var $bd, $button;
              $button = $(this);
              $bd = $button.data();
              if ($button.hasClass('query')) {
                $button.button('option', 'disabled', true);
                $button.on('click', function() {
                  var $params, $url;
                  $params = jQuery.param($('.param').serializeArray());
                  $url = "/sys/wstm/user/query?" + $params;
                  return Trst.desk.init($url);
                });
              }
              if ($button.hasClass('print')) {
                $button.on('click', function() {
                  var $url;
                  Trst.msgShow(Trst.i18n.msg.report.start);
                  $url = "/sys/wstm/user/print?" + $bd.url;
                  $.fileDownload($url, {
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
            });
          },
          init: function() {
            Wstm.desk.user.buttons($('button'));
            Wstm.desk.user.selects($('select.param,input.select2'));
            return $log('Wstm.desk.report.init() OK...');
          }
        }
      }
    });
    return Wstm.desk.user;
  });

}).call(this);
