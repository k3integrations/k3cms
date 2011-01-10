// 
// jQuery inline editor extension
// 
// 

$.fn.inlineEditor = function (options) {
  return this.each(function () {
    var editor;

    editor = $(this).data('inlineEditor');
    console.log("editor=", editor);
    if (editor) {
      // Update options on existing editor
      editor.mergeOptions($.extend(editor.options, options))
    } else {
      editor = new InlineEditor(this, options);
      $(this).data('inlineEditor', editor);
    }
  });
};

// no-op if console logger doesn't exist, so that errors aren't thrown
// this can be commented out if all debugging is commented out...
if (! window.console) {
  window.console = {
    log: function () {},
    debug: function () {}
  }
}

window.InlineEditor = function (node, options) {
  this.document = node.ownerDocument;
  this.window = this.document.defaultView;
  var $node = $(node);

  // set args
  this.node = node;
  //this.mergeOptions($.extend(InlineEditor.DEFAULT_OPTIONS, options, $node.data()));
  options = $.extend(InlineEditor.DEFAULT_OPTIONS, options, $node.data());
  $node.data(options);

  // set to editable, and hack for browsers that don't support isContentEditable (like FF3.6)
  node.contentEditable = true;
  if (! node.isContentEditable) {
    node.isContentEditable = true;
  }

  // initialize source/position for change/move detection
  this.lastSource = node.innerHTML;
  this.lastFocusNode = null;
  this.lastFocusOffset = 0;

  // bind event handlers
  $node.bind('focus.inline_editor'                           , {}                      , InlineEditor.defaultFocusHandler);
  $node.bind('blur.inline_editor'                            , {}                      , InlineEditor.defaultBlurHandler);
  $node.bind('livechange.inline_editor'                      , {}                      , InlineEditor.defaultLiveChangeHandler);
  $node.bind('save.inline_editor'                            , options.saveHandlerData , options.saveHandler || InlineEditor.defaultSaveHandler);

  $node.bind('blur mousedown mouseup keydown keyup keypress' , {}                      , InlineEditor.checkMoveOrChangeHandler);

  // special command to some browsers to coax them not to use style attributes as much!
  try {
    node.ownerDocument.execCommand('styleWithCSS', false, false);
  } catch (e) {
  }
};

window.InlineEditor.prototype.mergeOptions = function (options) {
  console.log('mergeOptions')
  console.log("options=", options);
  var $node = $(this.node);
  var options = $.extend($node.data(), options);
  $node.data(options);

  $node.unbind('focus.inline_editor')
  $node.unbind('blur.inline_editor')
  $node.unbind('livechange.inline_editor')
  $node.unbind('save.inline_editor')

  // TODO: don't duplicate with constructor! can we call this from constructor?
  $node.bind('focus.inline_editor'                           , {}                      , InlineEditor.defaultFocusHandler);
  $node.bind('blur.inline_editor'                            , {}                      , InlineEditor.defaultBlurHandler);
  $node.bind('livechange.inline_editor'                      , {}                      , InlineEditor.defaultLiveChangeHandler);
  $node.bind('save.inline_editor'                            , options.saveHandlerData , options.saveHandler || InlineEditor.defaultSaveHandler);
};

// checks if focus is currently on any active InlineEditor-editable object...
window.InlineEditor.isFocusedEditor = function () {
  return window.document.activeElement.isContentEditable && !! InlineEditor.focusedEditor();
};
// returns currently focused InlineEditor object instance...
window.InlineEditor.focusedEditor = function () {
  return InlineEditor.getEditor(window.document.activeElement);
};
// returns any editor instance that is attached directly to a given DOM node
window.InlineEditor.getEditor = function (node) {
  return $(node).data('inlineEditor');
};
// checks if focus is currently on this editable area instance...
window.InlineEditor.prototype.isFocused = function () {
  return this.document.activeElement === this.node && this.node.isContentEditable;
};
// shortcut to check if editable area hasn't been disabled
window.InlineEditor.prototype.isEnabled = function () {
  return this.node.isContentEditable;
};
// shortcut to check if editable area isan inline or block level element
window.InlineEditor.prototype.isInline = function () {
  return (this.node.currentStyle || window.getComputedStyle(this.node, null)).display == 'inline';
}

// exposing standard browser-built-in contentEditable editor commands...
// note these are NOT consistent cross browser
// so someday I expect I'll have eventually re-implemented all the useful ones...
window.InlineEditor.prototype.execCommand = function (cmd, arg) {
  if (this.isFocused()) {
    this.document.execCommand(cmd, false, arg);
    this.checkCursorMove();
    this.checkLiveChange();
  }
};
window.InlineEditor.prototype.queryCommandState = function (cmd, arg) {
  if (this.isFocused()) {
    return this.document.queryCommandState(cmd, false, arg);
  }
};
window.InlineEditor.prototype.queryCommandValue = function (cmd, arg) {
  if (this.isFocused()) {
    return this.document.queryCommandValue(cmd, false, arg);
  }
};
window.InlineEditor.prototype.queryCommandEnabled = function (cmd, arg) {
  if (this.isFocused()) {
    return this.document.queryCommandEnabled(cmd, false, arg);
  }
};

// reimplementation of document.execCommand('formatBlock', false, 'x') that behaves more consistently cross browser
window.InlineEditor.prototype.switchToBlock = function (type) {
  if (! this.isFocused()) {
    return;
  }
  this.getCurrentBlocks().each(function () {
    new InlineEditor.Element(this).changeTypeSafe(type);
  });
  this.getCurrentBlocklessContainers().each(function () {
    new InlineEditor.Element(this).wrapContentsWithTypeSafe(type);
  });
  this.getCurrentBlocklessRanges().each(function () {
    this.wrapWithTypeSafe(type);
  });
  this.checkCursorMove();
  this.checkLiveChange();
};
// reimplementation of document.queryCommandValue('formatBlock', false, 'x') that behaves more consistently cross browser
window.InlineEditor.prototype.isCurrentBlock = function (type) {
  var blocks, containers, ranges, type_blocks;
  if (! this.isFocused()) {
    return;
  }
  blocks = this.getCurrentBlocks();
  containers = this.getCurrentBlocklessContainers();
  ranges = this.getCurrentBlocklessRanges();
  type_blocks = blocks.filter(function () {
    return this.nodeName.toLowerCase() === type;
  });
  return containers.length === 0 && ranges.length === 0 && blocks.length > 0 && blocks.length === type_blocks.length;
};
// innards of the above two functions, need to find a proper home for it, it feels like cruft laying here...
// as we reimplement more of the built-in execCommand things for cross browser consistency, proper structure should become clear...
window.InlineEditor.TOGGLEABLE_BLOCK_TYPES = ['address', 'div', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'p', 'pre'];
window.InlineEditor.TOGGLEABLE_BLOCK_CONTAINER_TYPES = ['blockquote', 'dd', 'dt', 'li', 'td', 'th'];
window.InlineEditor.ALL_BLOCK_TYPES = ['address', 'blockquote', 'dd', 'div', 'dl', 'dt', 'form', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'li', 'ol', 'p', 'pre', 'table', 'tbody', 'td', 'tfoot', 'th', 'thead', 'tr', 'ul'];
window.InlineEditor.TOGGLEABLE_BLOCKS_SELECTOR = InlineEditor.TOGGLEABLE_BLOCK_TYPES.join(', ');
window.InlineEditor.TOGGLEABLE_BLOCK_CONTAINERS_SELECTOR = InlineEditor.TOGGLEABLE_BLOCK_CONTAINER_TYPES.join(', ');
window.InlineEditor.prototype.getCurrentBlocks = function () {
  var blocks;
  if (! this.isFocused()) {
    return [];
  }
  blocks = $(this.node).find(InlineEditor.TOGGLEABLE_BLOCKS_SELECTOR).not(':has(' + InlineEditor.TOGGLEABLE_BLOCK_CONTAINERS_SELECTOR + ')').filter(function () {
    return InlineEditor.Selection.intersectsNode(this);
  });
  return blocks;
};
window.InlineEditor.prototype.getCurrentBlocklessContainers = function () {
  var blocks;
  if (! this.isFocused()) {
    return [];
  }
  blocks = $(this.node).find(InlineEditor.TOGGLEABLE_BLOCK_CONTAINERS_SELECTOR).andSelf().not(':has(' + InlineEditor.TOGGLEABLE_BLOCKS_SELECTOR + ')').filter(function () {
    return InlineEditor.Selection.intersectsNode(this);
  });
  return blocks;
};
window.InlineEditor.prototype.getCurrentBlocklessRanges = function () {
  var blocks, range_border_nodes, ranges, selected_ranges;
  if (! this.isFocused()) {
    return [];
  }
  blocks = $(this.node).find(InlineEditor.TOGGLEABLE_BLOCK_CONTAINERS_SELECTOR).andSelf().has(InlineEditor.TOGGLEABLE_BLOCKS_SELECTOR);
  range_border_nodes = [];
  blocks.each(function () {
    var lastidx, lastnode, contents = $(this).contents();
    contents.each(function (idx) {
      var is_block = $.inArray(this.nodeName.toLowerCase(), InlineEditor.ALL_BLOCK_TYPES) > -1;
      if (! is_block && lastidx !== idx - 1) {
        range_border_nodes.push({start: this});
      } else if (is_block && lastidx === idx - 1) {
        range_border_nodes[range_border_nodes.length - 1].end = lastnode;
      }
      if (! is_block) {
        lastidx = idx;
        lastnode = this;
      }
    });
    if (range_border_nodes.length > 0 && ! range_border_nodes[range_border_nodes.length - 1].end) {
      range_border_nodes[range_border_nodes.length - 1].end = contents[contents.length - 1];
    }
  });
  ranges = $(range_border_nodes).map(function () {
    return new InlineEditor.Range(this.start, this.end);
  });
  selected_ranges = $(ranges).filter(function () {
    return InlineEditor.Selection.intersectsRange(this);
  });
  return selected_ranges;
};

// event handlers to check if custom events should fire
window.InlineEditor.checkMoveOrChangeHandler = function (evt) {
  var editor = InlineEditor.getEditor(this);
  editor.checkCursorMove();
  editor.checkLiveChange();
};
// if a move or change has occurred, trigger the custom 'livechange' and 'cursormove' events
// (normal dom 'change' events happen when focus is lost, not live as the change happens)
window.InlineEditor.prototype.checkCursorMove = function () {
  var sel = new InlineEditor.Selection(this.document), node = this.node;
  if (sel.anchorNode && sel.intersectsNode(this.node)) {
    if (! sel.equals(this.lastSelection) || node.innerHTML !== this.lastSource) {
      $(node).trigger('cursormove');
      this.lastSelection = sel;
    }
  } else if (this.lastSelection !== null) {
    $(node).trigger('cursormove');
    this.lastSelection = null;
  }
};
window.InlineEditor.prototype.checkLiveChange = function () {
  var node = this.node;
  if (node.innerHTML !== this.lastSource) {
    $(node).trigger('livechange');
    this.lastSource = node.innerHTML;
  }
};

// default event handlers
window.InlineEditor.defaultLiveChangeHandler = function (evt) {
  var $this = $(this), editor = InlineEditor.getEditor(this);
  // trigger the save handler after so many milliseconds of idle time
  if (editor.idleSaveTimeout) {
    clearTimeout(editor.idleSaveTimeout);
  }
  editor.idleSaveTimeout = setTimeout(function () {
    $this.trigger('save');
  }, $this.data('idle-save-time'));
};
window.InlineEditor.defaultFocusHandler = function (evt) {
  var $this = $(this);
  // add class that indicates it's currently being edited
  $this.addClass($this.data('editing-class'));
  // hack to fix Safari/Chrome, when moving focus from a form element!
  InlineEditor.Selection.putInNode(this);
};
window.InlineEditor.defaultBlurHandler = function (evt) {
  var $this = $(this), editor = InlineEditor.getEditor(this);
  // remove class that indicates it's currently being edited
  $this.removeClass($this.data('editing-class'));
  // remove the save timeout, and trigger the custom save event
  if (editor.idleSaveTimeout) {
    clearTimeout(editor.idleSaveTimeout);
    editor.idleSaveTimeout = null;
  }
  $this.trigger('save');
};

window.InlineEditor.defaultSaveHandler = function (evt) {
  console.log('in defaultSaveHandler')
  var $this = $(this), editor = InlineEditor.getEditor(this), post_url = $this.data('save-url');
  if (post_url) {
    $.ajax($.extend({
      type: $this.data('save-type'),
      url: post_url,
      data: editor.lastSource,
      success: function (data, msg, xhr) {
        $this.trigger('savesuccess', [data, msg, xhr]);
      },
      error:   function (xhr,  msg, err) {
        $this.trigger('saveerror',   [xhr,  msg, err]);
      }
    }, $this.data('ajax-options')));
  }
};

// default options
window.InlineEditor.DEFAULT_OPTIONS = {
  'editing-class': 'editing',
  'idle-save-time': 3000, // milliseconds
  'save-type': 'POST',
  saveHandlerData: {},
  saveHandler: null,
};


// --------------------
// InlineEditor.Element
// --------------------
// 
// added functionality not found in your typical various DOM element objects
// 

// constructor using a DOM Node, or a tag name string and optional Document
// one of either DOM Node or tag name string is required.
window.InlineEditor.Element = function (node, doc) {
  if (typeof(node) === 'string') {
    this.document = doc ? doc : window.document;
    this.window = this.document.defaultView;
    this.node = this.document.createElement(node);
  } else if (node.ownerDocument) {
    this.document = node.ownerDocument;
    this.window = this.document.defaultView;
    this.node = node;
  } else {
    throw 'element name or dom node is required for InlineEditor.Element constructor';
  }
  this.isInlineEditorElement = true;
};

// changes element to indicated element type, preserving selection, attributes, and contents
window.InlineEditor.Element.prototype.changeTypeSafe = function (type) {
  var elem = new InlineEditor.Element(type);
  $(this.node.attributes).each(function () {
    $(elem.node).attr(this.name, this.value);
  });
  this.replaceWithSafe(elem);
};
// wraps element contents with indicated element type, preserving selection and contents
window.InlineEditor.Element.prototype.wrapContentsWithTypeSafe = function (type) {
  this.wrapContentsSafe(new InlineEditor.Element(type));
};

// changes element to indicated InlineEditor.Element, preserving selection and contents
window.InlineEditor.Element.prototype.replaceWithSafe = function (elem) {
  var sel = InlineEditor.Selection.newForReplacingElement(this, elem);
  new InlineEditor.Range(this.document).replaceElementWithElement(this, elem);
  sel.restore();
};
// wraps element contents with indicated InlineEditor.Element, preserving selection and contents
window.InlineEditor.Element.prototype.wrapContentsSafe = function (elem) {
  var sel = InlineEditor.Selection.newForReplacingElement(this, elem);
  new InlineEditor.Range(this.document).wrapElementContentsWithElement(this, elem);
  sel.restore();
};

// --------------------
// InlineEditor.Range
// --------------------
// 
// handles ranges of text/tags (including partial elements) in a cross browser way
// adds additional functionality not in the standard DOM Range object.
// 

// constructor using optional indicated native Range, or a new one with indicated Document, or window.document
window.InlineEditor.Range = function (with_what, to_what) {
  // console.debug('new Range called with: ' + with_what + ', ' + to_what);
  this.document = InlineEditor.getDocumentFrom(with_what);
  if (this.document === null) {
    throw 'bad parameter for InlineEditor.Range constructor';
  } else {
    this.window = this.document.defaultView;
    this.range = this.document.createRange();
  }
  if (InlineEditor.Range.isSelectable(with_what) && (! to_what || InlineEditor.Range.isSelectable(to_what))) {
    this.select(with_what, to_what);
  }
  this.isInlineEditorRange = true;
  // console.debug('new Range returning');
};

// utility for getting a document object from a variety of objects...
window.InlineEditor.getDocumentFrom = function (with_what) {
  // console.debug('getDocumentFrom called with: ' + with_what);
  if (! with_what) {
    // console.debug('getDocumentFrom returning window.document: ' + window.document);
    return window.document;
  } else if (InlineEditor.isDocument(with_what)) {
    // console.debug('getDocumentFrom returning arg: ' + with_what);
    return with_what;
  } else if (with_what.anchorNode && with_what.anchorNode.ownerDocument) {
    // console.debug('getDocumentFrom returning arg.anchorNode.ownerDocument: ' + with_what.anchorNode.ownerDocument);
    return with_what.anchorNode.ownerDocument;
  } else if (with_what.document) {
    // console.debug('getDocumentFrom returning arg.document: ' + with_what.document);
    return with_what.document;
  } else if (with_what.ownerDocument) {
    // console.debug('getDocumentFrom returning arg.ownerDocument: ' + with_what.ownerDocument);
    return with_what.ownerDocument;
  } else {
    // console.debug('null');
    return null;
  }
};

// wraps current InlineEditor.Range with indicated element type, preserving selection and contents
window.InlineEditor.Range.prototype.wrapWithTypeSafe = function (type) {
  this.wrapWithElementSafe(new InlineEditor.Element(type));
};
// wraps current InlineEditor.Range with indicated InlineEditor.Element, preserving selection and contents
window.InlineEditor.Range.prototype.wrapWithElementSafe = function (elem) {
  var sel = new InlineEditor.Selection(this.document);
  this.wrapWithElement(elem);
  sel.restore();
};

// replaces an InlineEditor.Element with another, using ranges
window.InlineEditor.Range.prototype.replaceElementWithElement = function (old_elem, new_elem) {
  var contents = this.extractElementContentNodes(old_elem);
  this.deleteElementAndContents(old_elem);
  this.insertElement(new_elem, contents);
};
// wraps contents of an InlineEditor.Element with indicated InlineEditor.Element, using ranges
window.InlineEditor.Range.prototype.wrapElementContentsWithElement = function (old_elem, new_elem) {
  this.insertElement(new_elem, this.extractElementContentNodes(old_elem));
};
// wraps current InlineEditor.Range with indicated InlineEditor.Element
window.InlineEditor.Range.prototype.wrapWithElement = function (elem) {
  this.insertElement(elem, this.range.extractContents());
};

// selects, extracts (removes), and returns contents of indicated InlineEditor.Element
window.InlineEditor.Range.prototype.extractElementContentNodes = function (elem) {
  this.selectElementContents(elem);
  return this.range.extractContents();
};
// selects and deletes indicated InlineEditor.Element, and any contents it may contain
window.InlineEditor.Range.prototype.deleteElementAndContents = function (elem) {
  this.select(elem);
  this.range.deleteContents();
};

// insert InlineEditor.Element at beginning of current InlineEditor.Range, optionally populating it with given content node(s)
window.InlineEditor.Range.prototype.insertElement = function (elem, contents) {
  this.range.insertNode(elem.node);
  if (contents) {
    this.selectElementContents(elem);
    this.range.insertNode(contents);
  }
};

// checks if given argument can be selected with new InlineEditor.Range().select()
window.InlineEditor.Range.isSelectable = function (with_what) {
  // console.debug('Range isSelectable called with: ' + with_what);
  // console.debug('Range isSelectable return type: ' + (
  //   (with_what && with_what.anchorNode && with_what.focusNode && '1') ||
  //   (with_what && with_what.isInlineEditorElement && '2') ||
  //   (with_what && InlineEditor.isNode(with_what) && ! InlineEditor.isDocument(with_what) && '3')
  // ));
  return (with_what && with_what.anchorNode && with_what.focusNode) ||
    (with_what && with_what.isInlineEditorElement) ||
    (with_what && InlineEditor.isNode(with_what) && ! InlineEditor.isDocument(with_what));
};
// when given one arg: selects a given InlineEditor.Element, Selection, or DOM Node with current range
// when given two args: selects area inclusively between two InlineEditor.Element objects, Nodes, or Selections
window.InlineEditor.Range.prototype.select = function (with_what, to_what) {
  // console.debug('range select called with: ' + with_what + ', ' + to_what);
  if (with_what.anchorNode) {
    // alert(with_what.anchorNode + ' ' + with_what.anchorOffset);
    this.range.setStart(with_what.anchorNode, with_what.anchorOffset);
  } else {
    // console.debug('with_what: ' + (with_what.isInlineEditorElement ? with_what.node : with_what) + ', has node? ' + with_what.isInlineEditorElement);
    // console.debug('has setStartBefore: ' + this.range.setStartBefore);
    // console.debug('container: ' + (with_what.isInlineEditorElement ? with_what.node : with_what).ownerDocument);
    // console.debug('container type: ' + (with_what.isInlineEditorElement ? with_what.node : with_what).ownerDocument.nodeType);
    // console.debug('container name: ' + (with_what.isInlineEditorElement ? with_what.node : with_what).ownerDocument.nodeName);
    // console.debug('doc: ' + this.document);
    // console.debug('doc type: ' + this.document.nodeType);
    // console.debug('doc name: ' + this.document.nodeName);
    // console.debug('container === doc: ' + ((with_what.isInlineEditorElement ? with_what.node : with_what).ownerDocument === this.document));
    // console.debug('node type: ' + (with_what.isInlineEditorElement ? with_what.node : with_what).nodeType);
    // console.debug('node name: ' + (with_what.isInlineEditorElement ? with_what.node : with_what).nodeName);
    this.range.setStartBefore(with_what.isInlineEditorElement ? with_what.node : with_what);
    // console.debug('setStartBefore ran');
  }
  if (! to_what) {
    to_what = with_what;
  }
  if (to_what.focusNode) {
    this.range.setEnd(to_what.focusNode, to_what.focusOffset);
  } else {
    this.range.setEndAfter(to_what.isInlineEditorElement ? to_what.node : to_what);
  }
  // console.debug('range select returning');
};
// selects a given DOM Node with current range
window.InlineEditor.Range.prototype.selectNode = function (node) {
  try {
    this.range.selectNode(node);
  } catch (e) {
    this.range.selectNodeContents(node);
  }
};
// selects the contents of an InlineEditor.Element with current range
window.InlineEditor.Range.prototype.selectElementContents = function (elem) {
  this.selectNodeContents(elem.node);
};
// selects the contents of a DOM Node with current range
window.InlineEditor.Range.prototype.selectNodeContents = function (node) {
  this.range.selectNodeContents(node);
};

// tests if current range intersects an InlineEditor.Element
window.InlineEditor.Range.prototype.intersectsElement = function (elem) {
  return this.intersectsNode(elem.node);
};
// tests if current range intersects a DOM Node
window.InlineEditor.Range.prototype.intersectsNode = function (node) {
  // some browsers have this built in (FF<=2)
  if (this.range.intersectsNode) {
    return this.range.intersectsNode(node);
  } else {
    // otherwise emulate it with a second range (FF>=3, IE9)
    return this.intersectsRange(new InlineEditor.Range(node));
  }
};
// tests if current range intersects another InlineEditor.Range
window.InlineEditor.Range.prototype.intersectsRange = function (range) {
  return this.range.compareBoundaryPoints(Range.END_TO_START, range.range) === -1 &&
         this.range.compareBoundaryPoints(Range.START_TO_END, range.range) ===  1;
};


// --------------------
// InlineEditor.Selection
// --------------------
// 
// handles a selected area in a cross-browser way (does not support IE<=8)
// there is no real standard definition of a Selection object yet, so browsers naturally are inconsistent.
// 
// an instance of this object behaves very differently from the usual browser built-in Selection one
// in that it represents a 'snapshot' of what was selected when it was originally instantiated
// and does not change or become invalid as the document state or cursor position changes...
// 
// methods that examine or use the real current position are therefore class methods not instance methods
// (although those that manipulate the real position in relation to a snapshot are instance ones of course)
// 

window.InlineEditor.isDocument = function (doc) {
  return doc.documentElement && doc.defaultView;
};
window.InlineEditor.isSelection = function (sel) {
  alert(sel.anchorNode);
  return sel.anchorNode && sel.focusNode;
};
window.InlineEditor.isNode = function (node) {
  return node.ownerDocument;
}

// constructor takes an optional window object to base the selection on
window.InlineEditor.Selection = function (with_what) {
  var sel;
  if (! with_what) {
    this.window = window;
    this.document = this.window.document;
    sel = this.window.getSelection();
  } else if (InlineEditor.isDocument(with_what)) {
    this.window = with_what.defaultView;
    this.document = this.window.document;
    sel = this.window.getSelection();
  } else if (InlineEditor.isSelection(with_what)) {
    this.document = with_what.anchorNode.ownerDocument;
    this.window = this.document.defaultView;
    sel = with_what;
  } else {
    throw 'bad parameter for InlineEditor.Selection contructor';
  }
  this.anchorNode   = sel.anchorNode;
  this.anchorOffset = sel.anchorOffset;
  this.focusNode    = sel.focusNode;
  this.focusOffset  = sel.focusOffset;
  this.isInlineEditorSelection = true;
};

// tests if selection intersects indicated InlineEditor.Element
window.InlineEditor.Selection.prototype.intersectsElement = function (elem) {
  return this.intersectsNode(elem.node);
};
// tests if selection intersects indicated DOM Node
// some browsers like FF have an optimization for the current-selection version (Opera claims to have it, but it doesn't function!!)
window.InlineEditor.Selection.prototype.intersectsNode = function (node) {
  return new InlineEditor.Range(this).intersectsNode(node);
};
window.InlineEditor.Selection.intersectsNode = function (node) {
  var sel = node.ownerDocument.defaultView.getSelection();
  return sel.containsNode && ! navigator.userAgent.match(/Opera/) ? sel.containsNode(node, true) : new InlineEditor.Range(sel).intersectsNode(node);
};
// tests if selection intersects indicated InlineEditor.Range
window.InlineEditor.Selection.prototype.intersectsRange = function (range) {
  return new InlineEditor.Range(this).intersectsRange(range);
};
window.InlineEditor.Selection.intersectsRange = function (range) {
  return new InlineEditor.Range(range.window.getSelection()).intersectsRange(range);
};

// Saf/Chr will not properly put the cursor inside a contentEditable element, if you are moving focus from a form element!
// this fixes that (and does nothing if it wasn't broken), call it from the onfocus event to fix it
// algorithm: if cursor seems to be nowhere, put it at the beginning of the indicated node
window.InlineEditor.Selection.putInNode = function (node) {
  var sel = window.getSelection();
  if (! sel.anchorNode) {
    sel.collapse(node, 0);
  }
};

// change this selection to be in relation to a new node about to be inserted where an old node exists
// use when replacing the node, or putting a new node inside the old node spanning its entire contents
// this way the selection will still be valid after the change is made
window.InlineEditor.Selection.prototype.updateForReplacingElement = function (old_elem, new_elem) {
  this.updateForReplacingNode(old_elem.node, new_elem.node);
};
window.InlineEditor.Selection.prototype.updateForReplacingNode = function (old_node, new_node) {
  if (this.anchorNode === old_node) {
    this.anchorNode = new_node;
  }
  if (this.focusNode  === old_node) {
    this.focusNode  = new_node;
  }
};
window.InlineEditor.Selection.newForReplacingElement = function (old_elem, new_elem) {
  return InlineEditor.Selection.newForReplacingNode(old_elem.node, new_elem.node);
};
window.InlineEditor.Selection.newForReplacingNode = function (old_node, new_node) {
  var sel = new InlineEditor.Selection(old_node.ownerDocument);
  sel.updateForReplacingNode(old_node, new_node);
  return sel;
};

// reposition caret or reselect saved selection
window.InlineEditor.Selection.prototype.restore = function () {
  // preserving directionality of selection on browsers that support it (FF/Saf/Chr)
  var sel = this.window.getSelection();
  if (sel.collapse && sel.extend) {
    sel.collapse(this.anchorNode, this.anchorOffset);
    sel.extend(this.focusNode, this.focusOffset);
  } else {
    // or using a range for browsers that don't support preserving directionality (IE9)
    sel.removeAllRanges();
    sel.addRange(new InlineEditor.Range(this).range);
  }
};

// tests if two selection area instances point to an identical area
window.InlineEditor.Selection.prototype.equals = function (sel) {
  return !! sel &&
    this.anchorNode === sel.anchorNode && this.anchorOffset === sel.anchorOffset &&
    this.focusNode  === sel.focusNode  && this.focusOffset  === sel.focusOffset;
};
