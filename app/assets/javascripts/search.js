var ready = function(){
  search_autocomplete('#upgrade_to_leader_rescuer_input', '/search/users/normal_user', function(){});
  search_autocomplete('#downgrade_to_normal_user_input', '/search/users/lead_rescuer', function(){});
  search_autocomplete('#assign_event_user_input', '/search/users', function(){});
};

$(document).ready(ready);
$(document).on('page:load', ready);

function search_autocomplete(text_field_id, source_url, select_func){
  $(document).on("focus", text_field_id, function() {
    $(this).autocomplete({
      minLength : 1,
      delay : 100,
      source : source_url,
      open : function() {
        $('.ui-menu').width($(text_field_id).innerWidth());
        $('ul.ui-autocomplete').each(function() {
          x = $(this).position();
          $(this).css('top', x.top + 6);
        });
      },
      messages : {
        noResults : '',
        results : function() {
        }
      },
      focus : function() {
        // prevent value inserted on focus
        return false;
      },
      select : select_func
    });
  });
}