(function() {

  define(function() {
    $.extend(true, Wstm, {
      desk: {
        hmrs_employee: {
          init: function() {
            var _ref;
            if ((_ref = $('input.select2')) != null) {
              _ref.each(function() {
                var $ph, $sd, $select;
                $select = $(this);
                $sd = $select.data();
                $ph = Trst.i18n.select[Trst.desk.hdo.js_ext][$sd.ph];
                $select.select2({
                  placeholder: $ph,
                  minimumInputLength: $sd.minlength,
                  allowClear: true,
                  ajax: {
                    url: "/utils/search/" + $sd.search,
                    dataType: 'json',
                    quietMillis: 100,
                    data: function(term) {
                      return {
                        q: term
                      };
                    },
                    results: function(data) {
                      return {
                        results: data
                      };
                    }
                  }
                });
                $select.unbind();
                $select.on('change', function() {
                  Trst.desk.hdo.oid = $select.select2('val') === '' ? null : $select.select2('val');
                });
              });
            }
            $('button').each(function() {
              var $bd, $button;
              $button = $(this);
              $bd = $button.data();
              if ($bd.action === 'print') {
                return $button.on('click', function() {
                  var $url;
                  Trst.msgShow(Trst.i18n.msg.report.start);
                  $url = "/sys/wstm/hmrs/employee/print?id=" + Trst.desk.hdo.oid;
                  if ($bd.fn) {
                    $url += "&fn=" + $bd.fn;
                  }
                  if ($bd.ch_id) {
                    $url += "&ch_id=" + $bd.ch_id;
                  }
                  $.fileDownload($url, {
                    successCallback: function() {
                      return Trst.msgHide();
                    },
                    failCallback: function() {
                      Trst.msgHide();
                      return Trst.desk.downloadError(Trst.desk.hdo.model_name);
                    }
                  });
                  return false;
                });
              }
            });
            return $log('Wstm.desk.hmrs_employee.init() OK...');
          }
        }
      }
    });
    return Wstm.desk.hmrs_employee;
  });

}).call(this);
