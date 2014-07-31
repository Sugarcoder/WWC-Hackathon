var ready = function(){
  $('#event_date').datepicker({
    format: 'mm/dd/yyyy'
  });
  $('#event_starting_time').timepicker({
    defaultTime: false
  });
  $('#event_ending_time').timepicker({
    defaultTime: false
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

  parent.on('click', '#attend_event', function(e){  
    e.preventDefault();
    url =  "/events/attend/" + $(this).data('event-id') + "/attend";
    $.ajax({
      type : 'get',
      url : url,
      context: this,
      dataType : 'json',
      success : function(data) {
        $(this).hide();
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
  parent.on('click', '#wait_event', function(e){  
    e.preventDefault();
    url =  "/events/attend/" + $(this).data('event-id') + "/wait";
    $.ajax({
      type : 'get',
      url : url,
      context: this,
      dataType : 'json',
      success : function(data) {
        $(this).hide();
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
  parent.on('click', '#cancel_event', function(e){  
    e.preventDefault();
    url =  "/events/cancel/" + $(this).data('event-id') + "/attend";
    $.ajax({
      type : 'get',
      url : url,
      context: this,
      dataType : 'json',
      success : function(data) {
        $(this).hide();
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
    parent.on('click', '#cancel_waiting', function(e){  
    e.preventDefault();
    url =  "/events/cancel/" + $(this).data('event-id') + "/wait";
    $.ajax({
      type : 'get',
      url : url,
      context: this,
      dataType : 'json',
      success : function(data) {
        $(this).hide();
        $(this).parent().prepend('<a class="btn btn-success" href="/events/attend/' + data['event_id'] + '/wait" id="wait_event" data-event-id="' + data['event_id'] + '">Waiting List</a>');
        var count_span, block;
        if($('.modal').length > 0){
          block = $(this).closest('.modal');
        }
        else{
          block = $(this).closest('.event-block');
        }
        count_span = block.find('#event-waiting-list-count');
        var count = parseInt(count_span.text());
        if(count > 0){
          count_span.text(count - 1);
        }
      }
    });
  });

};

$(document).ready(ready);
$(document).on('page:load', ready);