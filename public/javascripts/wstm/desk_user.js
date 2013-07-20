(function() {

  define(function() {
    $.extend(true, Wstm, {
      desk: {
        user: {
          init: function() {
            $('#user_ids').select2({
              placeholder: 'Selectaţi min. un gestionar...',
              minimumInputLength: 0,
              multiple: true,
              data: $('#user_ids').data('data')
            });
            $('#user_ids').on('change', function() {
              if ($(this).select2('val').length) {
                return $('button.query').button('option', 'disabled', false);
              } else {
                return $('button.query').button('option', 'disabled', true);
              }
            });
            $('button.query').on('click', function() {
              var $url;
              $url = '/sys/wstm/user/query';
              $url += "?y=" + ($('#y').val()) + "&m=" + ($('#m').val());
              if ($('#user_ids').select2('val').length) {
                $url += "&user_ids=" + ($('#user_ids').select2('val'));
              }
              return Trst.desk.init($url);
            });
            $('button.query').button('option', 'disabled', true);
            $('button.print').button('option', 'disabled', true);
            return $log('Wstm.desk.report.init() OK...');
          }
        }
      }
    });
    return Wstm.desk.user;
  });

}).call(this);
