(function() {
  define(function() {
    $.extend(true, Wstm, {
      desk: {
        partner_firm: {
          init: function() {
            var _ref, _ref1;

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
            if ((_ref1 = $('select#y')) != null) {
              _ref1.each(function() {
                var $select;

                $select = $(this);
                $select.unbind();
                $select.on('change', function() {
                  var $url;

                  $url = "/sys/wstm/partner_firm/query?y=" + ($select.val());
                  Trst.desk.init($url);
                });
              });
            }
            $log('Wstm.desk.partner_firm.init() OK...');
            return $('button').each(function() {
              var $bd, $button;

              $button = $(this);
              $bd = $button.data();
              if ($bd.action === 'print') {
                return $button.on('click', function() {
                  var $url;

                  Trst.msgShow(Trst.i18n.msg.report.start);
                  $url = "/sys/wstm/report/print?rb=yearly_stats";
                  if ($bd.fn) {
                    $url += "&fn=" + $bd.fn;
                  }
                  if ($bd.uid) {
                    $url += "&uid=" + $bd.uid;
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
          }
        }
      }
    });
    return Wstm.desk.partner_firm;
  });

}).call(this);
