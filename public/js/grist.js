document.observe("dom:loaded", function() {
  new Ajax.Request('/fetch_progress',{method:'get',
    onSuccess: function(response) {
      if(response.responseText == "0") {
        $('initial_fetch').show();
      }
    }
  });
  new Ajax.Request('/update',{method:'get',
    onSuccess: function(response) {
      $('info_text').innerHTML = 'Please wait while Grist updates its local checkouts.<br/>This may take a while.';
      // $('initial_fetch').remove();
    }
  });
});
