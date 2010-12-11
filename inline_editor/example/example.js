$(document).ready(function () {
  initInlineEditor();
  
  // link source and html areas together to auto update each other
  $('#exampleSource')[0].value = $('#exampleHtml')[0].innerHTML;
  $('#exampleSource').bind('blur', function (evt) {
    $('#exampleHtml')[0].innerHTML = this.value;
  });
  $('#exampleHtml').bind('livechange', function (evt) {
    $('#exampleSource')[0].value = this.innerHTML;
  });
  $('#exampleHtml').bind('cursormove', function (evt) {
    var sel = window.getSelection();
    $('#anchorNode')[0].innerHTML    = sel.anchorNode;
    $('#anchorOffset')[0].innerHTML  = sel.anchorOffset;
    $('#focusNode')[0].innerHTML     = sel.focusNode;
    $('#focusOffset')[0].innerHTML   = sel.focusOffset;
  });

});
