(function() {

  define(function() {
    $.extend(true, Wstm, {
      desk: {
        partner_person: {
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
            return $log('Wstm.desk.partner_person.init() OK...');
          }
        }
      }
    });
    return Wstm.desk.partner_person;
  });

}).call(this);
