document.observe("dom:loaded", function() {
  $('update_button').disable();
  var spinner = new Spinner({length:30,width:20,radius:40}).spin($('info_spinner'));
  new Ajax.Request('/fetch_progress',{method:'get',
    onSuccess: function(response) {
      if(response.responseText == "0") {
        $('initial_fetch').show();
      }
    }
  });
  new Ajax.Request('/update_list',{method:'get',
    onSuccess: function(response) {
      $('info_text').innerHTML = 'Please wait while Grist updates its local checkouts.<br/>This may take a while.';
      new Ajax.Request('/update_checkouts',{method:'get',
        onSuccess: function(response) {
          $('info_text').innerHTML = 'Please wait while Grist updates its search index.<br/>This is the last step!';
          new Ajax.Request('/update_index',{method:'get',
            onSuccess: function(response) {
              $('info_text').innerHTML = 'All done. Thanks for waiting!';
              $('searchbox').enable();
              $('update_button').enable();
              spinner.stop();
              window.location = "/";
            }
          });
        }
      });
    }
  });
});
