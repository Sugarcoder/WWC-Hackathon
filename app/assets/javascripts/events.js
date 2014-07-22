var ready = function(){
  $('#event_date').datepicker({
    format: 'mm/dd/yyyy'
  });
  $('#event_time').timepicker({
    defaultTime: false
  });
  $('.selectpicker').selectpicker();


};

$(document).ready(ready);
$(document).on('page:load', ready);