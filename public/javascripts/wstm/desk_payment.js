(function() {

  define(function() {
    $.extend(true, Wstm, {
      desk: {
        payment: {
          init: function() {
            return $log('Wstm.desk.payment.init() OK...');
          }
        }
      }
    });
    return Wstm.desk.payment;
  });

}).call(this);
