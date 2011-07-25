(function() {
  var otherlib = (typeof jQuery == 'undefined' && typeof $ == 'function');
  // more or less stolen form jquery core and adapted by paul irish
  function getScript(url,success){
    var script=document.createElement('script');
    script.src=url;
    var head=document.getElementsByTagName('head')[0],
        done=false;
    // Attach handlers for all browsers
    script.onload=script.onreadystatechange = function(){
      if ( !done && (!this.readyState
           || this.readyState == 'loaded'
           || this.readyState == 'complete') ) {
        done=true;
        success();
        script.onload = script.onreadystatechange = null;
        head.removeChild(script);
      }
    };
    head.appendChild(script);
  }
  getScript('http://code.jquery.com/jquery-latest.min.js', function() {
    if (typeof jQuery == 'undefined') {
      alert('There was an error loading jquery');
    } else {
      jQuery.getScript('http://0.0.0.0:3000/reading.js');
    }
  });
})();
