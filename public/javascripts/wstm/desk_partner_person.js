(function() {
  define(function() {
    $.extend(true, Wstm, {
      desk: {
        partner_person: {
          calculate: function() {},
          updateDocAry: function(inpts) {
            var $params, $url;
            this.doc_ary = [];
            inpts.filter(':checked').each(function() {
              return Wstm.desk.partner_person.doc_ary.push(this.id);
            });
            inpts.filter('.param.doc_ary').val(this.doc_ary);
            $params = jQuery.param($('.param').serializeArray());
            $url = "/sys/partial/wstm/partner_person/_query_expenditures?" + $params;
            Trst.msgShow();
            $('td.query-expenditures-container').load($url, function() {
              Wstm.desk.partner_person.selects($('select.param'));
              Wstm.desk.partner_person.inputs($('input'));
              Trst.msgHide();
            });
          },
          inputs: function(inpts) {
            inpts.filter(':checkbox').on('change', function() {
              Wstm.desk.partner_person.updateDocAry(inpts);
            });
          },
          selects: function(slcts) {
            slcts.each(function() {
              var $ph, $sd, $select;
              $select = $(this);
              $sd = $select.data();
              if ($select.hasClass('select2')) {
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
                  var $params, $url;
                  if ($select.select2('val') === '') {
                    Trst.desk.hdo.oid = null;
                    if (Trst.desk.hdo.dialog === 'query') {
                      $url = "/sys/wstm/partner_person/query";
                      Trst.desk.init($url);
                      return;
                    }
                    return;
                  } else {
                    Trst.desk.hdo.oid = $select.select2('val');
                    if (Trst.desk.hdo.dialog === 'query') {
                      $params = jQuery.param($('.param').serializeArray());
                      $url = "/sys/partial/wstm/partner_person/_query_expenditures?" + $params;
                      Trst.msgShow();
                      $('td.query-expenditures-container').load($url, function() {
                        Wstm.desk.partner_person.selects($('select.param'));
                        Wstm.desk.partner_person.inputs($('input'));
                        Trst.msgHide();
                      });
                      return;
                    }
                    return;
                  }
                });
                return;
              } else if ($select.hasClass('param')) {
                $select.on('change', function() {
                  var $params, $url;
                  $('.param.doc_ary').val('');
                  $params = jQuery.param($('.param').serializeArray());
                  $url = "/sys/partial/wstm/partner_person/_query_expenditures?" + $params;
                  Trst.msgShow();
                  return $('td.query-expenditures-container').load($url, function() {
                    Wstm.desk.partner_person.selects($('select.param'));
                    Wstm.desk.partner_person.inputs($('input'));
                    Trst.msgHide();
                  });
                });
                return;
              } else {
                return;
              }
            });
          },
          buttons: function(btns) {
            btns.each(function() {
              var $bd, $button, ref;
              $button = $(this);
              $bd = $button.data();
              if (Trst.desk.hdo.dialog === 'filter') {
                if ((ref = $bd.action) === 'create' || ref === 'show' || ref === 'edit' || ref === 'delete') {
                  $bd.r_path = 'sys/wstm/partner_person/filter';
                }
              }
            });
          },
          init: function() {
            Wstm.desk.partner_person.buttons($('button'));
            Wstm.desk.partner_person.selects($('select.param, input.select2, input.repair'));
            Wstm.desk.partner_person.inputs($('input'));
            return $log('Wstm.desk.partner_person.init() OK...');
          }
        }
      }
    });
    return Wstm.desk.partner_person;
  });

}).call(this);
