var ready = function(){
  $('#starting-time').datetimepicker();
  $('#ending-time').datetimepicker();

  $("#starting-time").on("dp.change",function (e) {
     $('#ending-time').data("DateTimePicker").setMinDate(e.date);
  });
  
  $('.selectpicker').selectpicker();

  //show event receipt in finish event page
  $('.check_receipt_button').click(function(){
    $('.modal-body').empty();
    var title = $(this).attr("title");
    $('.modal-title').html(title);
    $($(this).next('#receipt_wrapper').html()).appendTo('.modal-body');
    $('#imageModal').modal('show');
  });

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

  create_category_pound_field($('#finish_event'));
  create_category_pound_field($('#edit_finish_event'));
};

$(document).ready(ready);

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

//Load more events in user page
$(document).on('click', "#loadmore_event", function(e){
  url =  "/users/" + $(this).data('user-id') + "/events/" +  $(this).data('event-type') + "?page=" + $(this).data('page');
  $.ajax({
    url: url,
    dataType: 'html',
    context: $(this),
    success: function(html){
      $(this).fadeOut("slow", function() { $(this).remove(); });
      $(this).closest('#user_events_wrapper').fadeIn( "slow", function(){ $(this).append(html) });
    }
  });
});

function create_category_pound_field(form_element){
  form_element.on('click', '#category-pound-add-button', function() {
    var $template = $('#category-pound-template'),
        $clone    = $template
                        .clone()
                        .removeClass('hide')
                        .removeAttr('id')
                        .insertBefore($template);
        $category_pound_option = $clone.find('[name="category_pound[]"]');
        $category_id_option    = $clone.find('[name="category_id[]"]');
    $clone.find('.category_id_picker').selectpicker('refresh');
    // Add new field
    //$('#surveyForm').bootstrapValidator('addField', $option);
  })
  .on('click', '#category-pound-remove-button', function() {
    var $row    = $(this).parents('.form-group'),
        $category_pound_option = $row.find('[name="category_pound[]"]'),
        $category_id_option    = $row.find('[name="category_id[]"]');

    // Remove element containing the option
    $row.remove();

    // Remove field
    //$('#surveyForm').bootstrapValidator('removeField', $option);
  });
}

function hide_event_modal(el){
  el.on('click', function(e){ 
    if( $(this).closest('#eventModal').length){ 
      $(this).closest('#eventModal').modal('hide');
    }
  });
}