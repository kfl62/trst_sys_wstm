(function() {
  define(function() {
    $.extend(true, Wstm, {
      desk: {
        selects: {
          handleUnit: function(node) {
            var $select;
            $select = node;
            $select.on('change', function() {
              var $dialog, $model;
              if ($select.val() === 'null') {
                Wstm.unit_info.update();
              } else {
                Wstm.unit_info.update($select.find('option:selected').text());
              }
              $model = Trst.desk.hdo.js_ext.split(/_(.+)/)[1];
              $dialog = Trst.desk.hdo.dialog;
              Trst.desk.init("/utils/units/wstm/" + $model + "/" + $dialog + "/" + ($select.val()));
            });
          },
          init: function() {
            this.handleUnit($('select[data-mark~=unit]'));
            return $log('Wstm.selects.init() OK...');
          }
        }
      }
    });
    return Wstm.desk.selects;
  });

}).call(this);
