$(document).ready(function () {
  module('Range');
  
  test('constructor with no parameters', 6, function () {
    var r = new InlineEditor.Range();
    ok(r);
    strictEqual(r.window, window);
    strictEqual(r.document, window.document);
    ok(r.range);
    ok(r.range.collapsed);
    strictEqual(r.range.startContainer, document);
  });
  test('constructor with a document', 6, function () {
    var r = new InlineEditor.Range(document);
    ok(r);
    strictEqual(r.window, window);
    strictEqual(r.document, window.document);
    ok(r.range);
    ok(r.range.collapsed);
    strictEqual(r.range.startContainer, document);
  });
  test('constructor with an element', 9, function () {
    var elem_node = $('#elem')[0];
    var elem = new InlineEditor.Element(elem_node);
    var parent_elem_node = $('#parent')[0];
    var r = new InlineEditor.Range(elem);
    ok(r);
    strictEqual(r.window, window);
    strictEqual(r.document, window.document);
    ok(r.range);
    ok(! r.range.collapsed);
    strictEqual(r.range.startContainer, parent_elem_node);
    strictEqual(r.range.startOffset, 0);
    strictEqual(r.range.endContainer, parent_elem_node);
    strictEqual(r.range.endOffset, 1);
  });
  test('constructor with a dom node', 9, function () {
    var elem_node = $('#elem')[0];
    var elem = new InlineEditor.Element(elem_node);
    var parent_elem_node = $('#parent')[0];
    var r = new InlineEditor.Range(elem_node);
    ok(r);
    strictEqual(r.window, window);
    strictEqual(r.document, window.document);
    ok(r.range);
    ok(! r.range.collapsed);
    strictEqual(r.range.startContainer, parent_elem_node);
    strictEqual(r.range.startOffset, 0);
    strictEqual(r.range.endContainer, parent_elem_node);
    strictEqual(r.range.endOffset, 1);
  });
  test('constructor with a selection', 9, function () {
    var elem_node = $('#elem')[0];
    var elem = new InlineEditor.Element(elem_node);
    elem_node.innerHTML = 'abcd';
    var txt_node = elem_node.childNodes[0];
    // alert(elem_node.ownerDocument.defaultView.getSelection());
    // var sel = window.getSelection();
    var sel = elem_node.ownerDocument.defaultView.getSelection();
    // alert(sel);
    // alert(sel.anchorNode);
    // if (sel.collapse && sel.extend) { // FF/Saf/Chr
    //   sel.collapse(txt_node, 1);
    //   sel.extend(txt_node, 3);
    // } else { // IE9
      var range = elem_node.ownerDocument.createRange();
      // alert((elem_node.ownerDocument === txt_node.ownerDocument) + ' ' + range.setStart);
      // alert(txt_node.length + ' ' + txt_node.childNodes + ' ' + txt_node.substringData(1, 1));
      // range.setEnd(txt_node, 2);
      range.setStart(txt_node, 1);
      // alert(range.setEnd);
      range.setEnd(txt_node, 3);
      sel.removeAllRanges();
      sel.addRange(range);
    // } 
    var r = new InlineEditor.Range(sel);
    ok(r);
    strictEqual(r.window, window);
    strictEqual(r.document, window.document);
    ok(r.range);
    ok(! r.range.collapsed);
    strictEqual(r.range.startContainer, txt_node);
    strictEqual(r.range.startOffset, 1);
    strictEqual(r.range.endContainer, txt_node);
    strictEqual(r.range.endOffset, 3);
    elem_node.innerHTML = '';
  });
  
  test('intersectsNode fully containing', 4, function () {
    var elem_node = $('#elem')[0];
    var elem = new InlineEditor.Element(elem_node);
    elem_node.innerHTML = '<div id="outer">a<span id="inner">b</span>c</div>';
    var outer_range = new InlineEditor.Range($('#outer')[0]);
    var inner_range = new InlineEditor.Range($('#inner')[0]);
    ok(outer_range);
    ok(inner_range);
    ok(outer_range.intersectsRange(inner_range));
    ok(inner_range.intersectsRange(outer_range));
    elem_node.innerHTML = '';
  });
  
  // test('intersectsNode overlapping', 4, function () {
  //   elem_node.innerHTML = '<div id="one">one</div>between<div id="two">two</div>';
  //   var outerrange = new InlineEditor.Range(new InlineEditor.Element($('#outer')[0]));
  //   var innerrange = new InlineEditor.Range(new InlineEditor.Element($('#inner')[0]));
  //   ok(outerrange);
  //   ok(innerrange);
  //   ok(outerrange.intersectsRange(innerrange));
  //   ok(innerrange.intersectsRange(outerrange));
  //   elem_node.innerHTML = '';
  // });
  
});
