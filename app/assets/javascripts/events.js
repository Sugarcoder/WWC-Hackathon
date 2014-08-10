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

  $(document).on('click', '#attend_event', function(e){  
    e.preventDefault();
    $(this).hide();
    url =  "/events/attend/" + $(this).data('event-id') + "/attend";
    $.ajax({
      type : 'get',
      url : url,
      context: this,
      dataType : 'json',
      success : function(data) {
        $(this).parent().prepend('<a class="btn btn-danger" href="/events/cancel/' + data['event_id'] + '/attend" id="cancel_event" data-event-id="' + data['event_id'] + '">Cancel</a>');
        var count_span, block;
        if($('.modal').length > 0){
          block = $(this).closest('.modal');
        }
        else{
          block = $(this).closest('.event-block');
        }
        count_span = block.find('#event-attending-count');
        max_span =  block.find('#max-attending-count');
        var count = parseInt(count_span.text());
        var max = parseInt(max_span.text());
        if(count < max){
          count_span.text(count + 1);
        }
      }
    });
  });

  //waiting event
  $(document).on('click', '#wait_event', function(e){  
    e.preventDefault();
    $(this).hide();
    url =  "/events/attend/" + $(this).data('event-id') + "/wait";
    $.ajax({
      type : 'get',
      url : url,
      context: this,
      dataType : 'json',
      success : function(data) {
        $(this).parent().prepend('<a class="btn btn-danger" href="/events/cancel/' + data['event_id'] + '/wait" id="cancel_waiting" data-event-id="' + data['event_id'] + '">Cancel</a>');
        var count_span, block;
        if($('.modal').length > 0){
          block = $(this).closest('.modal');
        }
        else{
          block = $(this).closest('.event-block');
        }
        count_span = block.find('#event-waiting-list-count');
        max_span =  block.find('#max-waiting-list-count');
        var count = parseInt(count_span.text());
        var max = parseInt(max_span.text());
        if(count < max){
          count_span.text(count + 1);
        }
      }
    });
  });

  //cancel event
  $(document).on('click', '#cancel_event', function(e){  
    e.preventDefault();
    $(this).hide();
    url =  "/events/cancel/" + $(this).data('event-id') + "/attend";
    $.ajax({
      type : 'get',
      url : url,
      context: this,
      dataType : 'json',
      success : function(data) {
        $(this).parent().prepend('<a class="btn btn-success" href="/events/attend/' + data['event_id'] + '/attend" id="attend_event" data-event-id="' + data['event_id'] + '">Attend</a>');
         var count_span, block;
        if($('.modal').length > 0){
          block = $(this).closest('.modal');
        }
        else{
          block = $(this).closest('.event-block');
        }
        count_span = block.find('#event-attending-count');
        var count = parseInt(count_span.text());
        if(count > 0){
          count_span.text(count - 1);
        }
      }
    });
  });

  //cancel wait
  $(document).on('click', '#cancel_waiting', function(e){  
    e.preventDefault();
    $(this).hide();
    url =  "/events/cancel/" + $(this).data('event-id') + "/wait";
    $.ajax({
      type : 'get',
      url : url,
      context: this,
      dataType : 'json',
      success : function(data) {
        $(this).parent().prepend('<a class="btn btn-success" href="/events/attend/' + data['event_id'] + '/wait" id="wait_event" data-event-id="' + data['event_id'] + '">Waiting List</a>');
        var count_span, block;
        if($('.modal').length > 0){
          var block = $(this).closest('.modal');
        }
        else{
          var block = $(this).closest('.event-block');
        }
        var count_span = block.find('#event-waiting-list-count');
        var count = parseInt(count_span.text());
        if(count > 0){
          count_span.text(count - 1);
        }
      }
    });
  });

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