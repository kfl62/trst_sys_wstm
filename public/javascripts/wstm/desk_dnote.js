(function() {

  define(function() {
    $.extend(true, Wstm, {
      desk: {
        dnote: {
          init: function() {
            return $msg('Wstm.desk.dnote.init() OK...');
          }
        }
      }
    });
    return Wstm;
  });

}).call(this);
