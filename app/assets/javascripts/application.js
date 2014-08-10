// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//

//= require jquery
//= require jquery_ujs
//= require ./plugins/bootstrap-select.js
//= require moment
//= require bootstrap-datetimepicker
//= require bootstrap-sprockets
//= require turbolinks
//= require_tree .

var ready = function(){

  //Automatically close (fade away) the alert message after 5 seconds
  window.setTimeout(function() {
    $(".alert").fadeTo(1500, 0).slideUp(500, function(){
        $(this).remove(); 
    });
  }, 5000);

  //remove hidden bootstrap modal in calendar page
  $('body').on('hidden.bs.modal', '#eventModal', function () {
    $(this).removeData("bs.modal").find(".modal-content").empty();
  });
};

$(document).ready(ready);
$(document).on('page:load', ready);