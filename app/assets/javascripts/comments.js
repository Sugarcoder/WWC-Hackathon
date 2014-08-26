$(document).on('click', '.comment-remove-icon', function(){
  var remove_comment_url = '/comments/' + $(this).data('comment-id');
  $.ajax({
    type: 'DELETE',
    dataType: 'json',
    context: $(this),
    url: remove_comment_url,
    success: function(data){
      if(data['error']){
        alert(data['message']);
      }
      else{
        $(this).closest('.media').fadeOut("slow", function() { $(this).remove(); });
      }
    }
  });
});

$(document).on('click', '#loadmore_comment', function(){
  var loadmore_url = '/comments/' + $(this).data('event-id') + '/' +  $(this).data('page');
  $.ajax({
    dataType: 'html',
    url: loadmore_url,
    context: $(this),
    success: function(html){
      console.log(html)
      $(this).parent().fadeOut("slow", function() { $(this).remove(); });
      $(this).closest('.media-list').fadeIn( "slow", function(){ $(this).append(html) });
    }
  });
});