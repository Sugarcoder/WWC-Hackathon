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
//= require jquery.turbolinks
//= require jquery_ujs
//= require jquery-ui/autocomplete
//= require ./plugins/bootstrap-select.js
//= require ./plugins/jquery.form.js
//= require moment
//= require bootstrap-datetimepicker
//= require bootstrapValidator.min
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

  //validator for finish event form
  $('#finish_event').bootstrapValidator({
    excluded: [':disabled', ':hidden', ':not(:visible)'],
    feedbackIcons: {
      required: 'glyphicon glyphicon-asterisk',
      valid: 'glyphicon glyphicon-ok',
      invalid: 'glyphicon glyphicon-remove',
      validating: 'glyphicon glyphicon-refresh'
    },
    fields: {
      'pound': {
        message: 'The pound field is not valid',
        validators: {
          notEmpty: {
            message: 'Pound is required and cannot be empty'
          },
          integer: {
            message: 'The value is not an integer'
          },
          greaterThan: {
            message: 'Pound should >= 0',
            value: -1
          }
        }
      },
      'receipt': {
        enabled: false,
        validators: {
          notEmpty: {
            message: 'receipt is required and cannot be empty'
          }
        }
      }
    }
  })
  .on('keyup', '[name="pound"]', function() {
    var pound = $(this).val();
    // if pound value is '0', disable the receipt validator. other wise enable it.
    $('#finish_event').bootstrapValidator('enableFieldValidators', 'receipt', pound !== '0')
    // Revalidate the field when user start typing in the password field
    if ($(this).val().length == 1) {
      $('#finish_event').bootstrapValidator('validateField', 'receipt')
    }
  });


  //validator for user sign up form
  $('#new_user').bootstrapValidator({
      excluded: [':disabled', ':hidden', ':not(:visible)'],
      feedbackIcons: {
        required: 'glyphicon glyphicon-asterisk',
        valid: 'glyphicon glyphicon-ok',
        invalid: 'glyphicon glyphicon-remove',
        validating: 'glyphicon glyphicon-refresh'
      },
      fields: {
        'user[username]': {
          message: 'The username is not valid',
          validators: {
            notEmpty: {
              message: 'Field is required and cannot be empty'
            },
            remote: {
              message: 'The username is taken by other user',
              url: '/users/check-username'
            },
            stringLength: {
                min: 4,
                max: 20,
                message: 'Please enter value between %s and %s characters long'
            },
            regexp: {
              regexp: /^[a-zA-Z0-9_]+$/i,
              message: 'The username can consist of alphabetical characters, numbers and "_" only '
            }
          }
        },
        'user[email]': {
          message: 'The email is not valid',
          validators: {
            notEmpty: {
              message: 'Email is required and cannot be empty'
            },
            remote: {
                message: 'The username is taken by other user',
                url: '/users/check-email'
            }
          }
        },
        'user[password]': {
          validators: {
            notEmpty: {
              message: 'The password is required and cannot be empty'
            },
            callback: {
                message: 'The password is not valid',
                callback: function(value, validator, $field) {
                    if (value === '') {
                        return true;
                    }
                    // Check the password strength
                    if (value.length < 8) {
                        return {
                            valid: false,
                            message: 'It must be more than 8 characters long'
                        };
                    }
                    // The password doesn't contain any uppercase character
                    if (value === value.toLowerCase()) {
                        return {
                            valid: false,
                            message: 'It must contain at least one upper case character'
                        }
                    }

                    // The password doesn't contain any uppercase character
                    if (value === value.toUpperCase()) {
                        return {
                            valid: false,
                            message: 'It must contain at least one lower case character'
                        }
                    }

                    // The password doesn't contain any digit
                    if (value.search(/[0-9]/) < 0) {
                        return {
                            valid: false,
                            message: 'It must contain at least one digit'
                        }
                    }

                    return true;
                }
            }
          }
        },
        'user[password_confirmation]': {
          validators: {
              notEmpty: {
                message: 'Field is required and cannot be empty'
              },
              identical: {
                  field: 'user[password]',
                  message: 'The password and its confirm are not the same'
              }
          }
        },
        'user[firstname]': {
         
          validators: {
            notEmpty: {
              message: 'First name is required and cannot be empty'
            },
            regexp: {
              regexp: /^[a-z\s]+$/i,
              message: 'Name can consist of alphabetical characters and spaces only'
            }
          }
        },
        'user[lastname]': {
          validators: {
            notEmpty: {
              message: 'Last name is required and cannot be empty'
            },
            regexp: {
              regexp: /^[a-z\s]+$/i,
              message: 'Name can consist of alphabetical characters and spaces only'
            }
          }
        },
        'user[telephone]': {
          validators: {
            notEmpty: {
              message: 'Phone number is required and cannot be empty'
            },
            phone: {
              country: 'US',
              message: 'The value is not a valid US phone number'
            }
          }
        },
        'user[organization]': {
          validators: {
            notEmpty: {
              message: 'Organization is required and cannot be empty'
            },
          }
        },
        'terms_and_policy': {
          validators: {
            notEmpty: {
              message: 'You need to agree on the terms & conditions and photo release policy'
            },
          }
        }
      }
  });

};

$(document).ready(ready);



$(document).on("keyup", "#comment_text", function(e) {

  if (e.keyCode == 13) {
    $('#comment_text').preventDoubleSubmission();
    var textarea = $(this).closest('.media');
    textarea.after('<li class="media">' + '</li>');
    var target = textarea.next();
    var options = {
      target: target,
      success : function() {
        $(this).fadeIn('slow');
      },
      error : function() {
    
      },
      resetForm : true
    };
    
    $(this).closest("form").ajaxForm(options).submit();
    $(this).val('').empty();
  }

});


jQuery.fn.preventDoubleSubmission = function() {
  $(this).on('submit', function(e) {
    var $form = $(this);

    if ($form.data('submitted') === true) {
      // Previously submitted - don't submit again
      e.preventDefault();
    } else {
      // Mark it so that the next submit can be ignored
      $form.data('submitted', true);
    }
  });

  // Keep chainability
  return this;
};
