(function(d, s, id){
  var js, fjs = d.getElementsByTagName(s)[0];
  if (d.getElementById(id)) {return;}
  js = d.createElement(s); js.id = id;
  js.src = "//connect.facebook.com/en_US/messenger.Extensions.js";
  fjs.parentNode.insertBefore(js, fjs);
}(document, 'script', 'Messenger'));

window.extAsyncInit = function() {
  // MessengerExtensions.getUserID(function success(uids) {
  //   // User ID was successfully obtained.
  //   var psid = uids.psid;
  // }, function error(err, errorMessage) {
  //   // Error handling code
  // });

  // $('#base_url').val();

  // $(".location-input").on('change', function() {
  //   var location = $('input[name=location]:checked').val();

  //   MessengerExtensions.requestCloseBrowser(function success() {

  //   }, function error(err, errorMessage) {

  //   });
  // });
};
