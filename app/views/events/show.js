$("#eventModal .modal-content").html("<%= escape_javascript(render partial: 'event_modal', locals: {event: @event}) %>");
$('#eventModal').modal('show');