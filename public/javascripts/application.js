// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(function() {
  $("a").click(function(){
    link_host = this.href.split("/")[2];
    document_host = document.location.href.split("/")[2];

    if (link_host != document_host) {
      window.open(this.href);
      return false;
    }
  });

  var bookmarklet_hover = function(){
    var $this = $('a.bookmarklet'),
        alt = $this.attr('alt');
    $this
      .attr('alt', $this.text())
      .text(alt);
  };
  bookmarklet_hover(); // call this on load so that the browser bookmark bar shows the right text

  $("a.bookmarklet").hover(bookmarklet_hover, bookmarklet_hover);

});
