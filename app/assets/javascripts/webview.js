(function(d, s, id){
  var js, fjs = d.getElementsByTagName(s)[0];
  if (d.getElementById(id)) {return;}
  js = d.createElement(s); js.id = id;
  js.src = "//connect.facebook.com/en_US/messenger.Extensions.js";
  fjs.parentNode.insertBefore(js, fjs);
}(document, 'script', 'Messenger'));

window.extAsyncInit = function() {
  $(".location-input").on('change', function() {
    var location = $('input[name=location]:checked').val();

    MessengerExtensions.getUserID(function success(uids) {
      var psid = uids.psid;
      var base_url = $('#base_url').val() + '/webview/reply_to_location';
      $.post(base_url,
        {
          location: location,
          uid: psid
        },
        function(data, status){
          MessengerExtensions.requestCloseBrowser(function success() {
            // OK to close browser
          }, function error(err, errorMessage) {
            console.log('Cannot close browser: ' + errorMessage);
          });
        });
    }, function error(err, errorMessage) {
      console.log('Cannot get UID: ' + errorMessage);
    });
  });
};
