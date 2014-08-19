var ready = function(){
  $('#starting-time').datetimepicker();
  $('#ending-time').datetimepicker();

  $("#starting-time").on("dp.change",function (e) {
     $('#ending-time').data("DateTimePicker").setMinDate(e.date);
  });
  
  $('.selectpicker').selectpicker();

  //attend event js 
  var parent;
  if($('.modal').length > 0){
    parent = $('.modal');
  }
  else{
    parent = $('.event-block');
  }

  hide_event_modal($('#attend_event'));
  hide_event_modal($('#wait_event'));
  hide_event_modal($('#cancel_event'));
  hide_event_modal($('#cancel_waiting'));

  //stop recurring
  $(document).on('click', '#confirm_stop_recurring', function(e){
    e.preventDefault();
    url =  "/events/recurring/" + $(this).data('event-id');
    $.ajax({
      type : 'delete',
      url : url,
      context: this,
      dataType : 'json',
      success : function(data){
        $('#stop_recurring').hide();
        var event_recurring_type = $('#event_recurring_type');
        event_recurring_type.selectpicker('val', 'not_recurring');
        event_recurring_type.prop('disabled',false);
        event_recurring_type.selectpicker('refresh');
        $(this).closest('.modal').modal('hide');
      }
    });
  });

};

$(document).ready(ready);
$(document).on('page:load', ready);

function hide_event_modal(el){
  el.on('click', function(e){ 
    if( $(this).closest('#eventModal').length){ 
      $(this).closest('#eventModal').modal('hide');
    }
  });
}