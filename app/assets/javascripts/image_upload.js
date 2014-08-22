var ready = function(){
  $(document).on('change', '#avatar', fileSelectHandler);

  // convert bytes into friendly format
  function bytesToSize(bytes) {
      var sizes = ['Bytes', 'KB', 'MB'];
      if (bytes == 0) return 'n/a';
      var i = parseInt(Math.floor(Math.log(bytes) / Math.log(1024)));
      return (bytes / Math.pow(1024, i)).toFixed(1) + ' ' + sizes[i];
  };

  // update info by cropping (onChange and onSelect events handler)
  function updateInfo(e) {
      $('#crop_x').val(e.x);
      $('#crop_y').val(e.y);
      $('#crop_w').val(e.w);
      $('#crop_h').val(e.h);
  };

  // Create variables (in this scope) to hold the Jcrop API and image size
  var jcrop_api, boundx, boundy;

  function fileSelectHandler() {

    // get selected file
    var oFile = $('#avatar')[0].files[0];

    // hide all errors
    $('.error').hide();

    // check for image type (jpg and png are allowed)
    var rFilter = /^(image\/jpeg|image\/png)$/i;
    if (! rFilter.test(oFile.type)) {
        $('.error').html('Please select a valid image file (jpg and png are allowed)').show();
        return;
    }

    // preview element
    var oImage = document.getElementById('preview');

    // prepare HTML5 FileReader
    var oReader = new FileReader();
        oReader.onload = function(e) {

        // e.target.result contains the DataURL which we can use as a source of the image
        oImage.src = e.target.result;
        oImage.onload = function () { // onload event handler

            // display step 2
            $('.step2').fadeIn(500);

            // destroy Jcrop if it is existed
            if (typeof jcrop_api != 'undefined') {
                jcrop_api.destroy();
                jcrop_api = null;
                $('#preview').width(oImage.naturalWidth);
                $('#preview').height(oImage.naturalHeight);
            }

           
            // initialize Jcrop
            $('#preview').Jcrop({
                minSize: [32, 32], // min crop size
                aspectRatio : 1, // keep aspect ratio 1:1
                bgFade: true, // use fade effect
                bgOpacity: .3, // fade opacity
                onChange: updateInfo,
                onSelect: updateInfo,
                boxHeight: 500,
                boxWidth: 500,
            }, function(){

            // use the Jcrop API to get the real image size
            var bounds = this.getBounds();
            boundx = bounds[0];
            boundy = bounds[1];

            // Store the Jcrop API in the jcrop_api variable
            jcrop_api = this;
            });
           

        };
    };

    // read selected file as DataURL
    oReader.readAsDataURL(oFile);
  }

};

$(document).ready(ready);
$(document).on('page:load', ready);

