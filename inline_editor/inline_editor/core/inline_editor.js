//==================================================================================================
// jQuery inline editor extension
// 

$.fn.inlineEditor = function (options) {
  return this.each(function () {
    var editor;

    editor = $(this).data('inlineEditor');
    //console.log("editor=", editor);
    if (editor) {
      // Update options on existing editor
      editor.updateOptions($.extend(editor.options, options))
    } else {
      editor = new InlineEditor(this, options);
      $(this).data('inlineEditor', editor);
    }
  });
};

//==================================================================================================
// InlineEditor class

InlineEditor = function (node, options) {
  this.document = node.ownerDocument;
  this.window = this.document.defaultView;
  this.node = node;
  var $node = $(node);

  //console.log("merging options=", options, " and $node.data()=", $.extend({}, $node.data()));
  options = $.extend({}, InlineEditor.DEFAULT_OPTIONS, options, $node.data());
  // TODO: store 'this' instead and access options as a property of InlineEditor object
  $node.data(options);

  // set to editable, and hack for browsers that don't support isContentEditable (like FF3.6)
  node.contentEditable = true;
  if (! node.isContentEditable) {
    node.isContentEditable = true;
  }

  // initialize source/position for change/move detection
  this.lastSource      =
  this.lastSourceSaved = node.innerHTML;
  this.lastFocusNode = null;
  this.lastFocusOffset = 0;

  this.bindEventHandlers();

  $node.bind('blur mousedown mouseup keydown keyup keypress' , {}, InlineEditor.checkMoveOrChangeHandler);

  // special command to some browsers to coax them not to use style attributes as much!
  try {
    node.ownerDocument.execCommand('styleWithCSS', false, false);
  } catch (e) { }
};

//--------------------------------------------------------------------------------------------------
// Instance methods

$.extend(InlineEditor.prototype, {
  updateOptions: function (options) {
    //console.log('updateOptions')
    //console.log("options=", options);
    var $node = $(this.node);
    var options = $.extend($node.data(), options);
    $node.data(options);
    this.bindEventHandlers();
  },

  $node: function() {
    return $(this.node);
  },

  getConf: function () {
    // TODO: store this in data instead so we can just use this.options here instead
    var $node = $(this.node);
    return $node.data();
  },
  bindEventHandlers: function () {
    //var options = this.getConf();
    var $node = $(this.node);
    var options = $node.data();

    $node.unbind('.inline_editor')
    $node.bind('focus.inline_editor'          , {}, InlineEditor.focusHandler);
    $node.bind('custom_focus.inline_editor'   , {}, options.focus);
    $node.bind('blur.inline_editor'           , {}, options.blur);
    $node.bind('live_change.inline_editor'    , {}, options.liveChange);
    $node.bind('onBeforeSave.inline_editor'   , {}, options.onBeforeSave);
    $node.bind('saving.inline_editor'         , {}, options.saving);
    $node.bind('save.inline_editor'           , {}, options.save);
    $node.bind('save_success.inline_editor'   , {}, options.saveSuccess);
    $node.bind('save_error.inline_editor'     , {}, options.saveError);
    $node.bind('save_if_changed.inline_editor', {}, InlineEditor.saveIfChanged);
    $node.bind('focusout.inline_editor'       , {}, InlineEditor.focusout);
    var self = this;
    $node.find(InlineEditor.SUB_FOCUSABLE_SELECTOR).each(function() {
      self.bindSubEventHandlersToNode(this);
    });
  },
  bindSubEventHandlersToNode: function (node) {
    var $node = $(node);
    $node.unbind('.inline_editor');
    $node.bind('focus.inline_editor', {}, InlineEditor.subFocusHandler);
    $node.bind('blur.inline_editor' , {}, InlineEditor.subBlurHandler);
  },

  // checks if focus is currently on this editable area instance...
  isFocused: function () {
    var focused_elem = window.document.activeElement;
    if (! focused_elem) return false;
    var editor = InlineEditor.getEditorOrParentEditor(focused_elem);
    return !! editor && editor === this && editor.isEnabled();
  },
  // shortcut to check if editable area hasn't been disabled
  isEnabled: function () {
    return this.node.isContentEditable;
  },
  // shortcut to check if editable area isan inline or block level element
  isInline: function () {
    return (this.node.currentStyle || window.getComputedStyle(this.node, null)).display == 'inline';
  },

  // exposing standard browser-built-in contentEditable editor commands...
  // note these are NOT consistent cross browser
  // so someday I expect I'll have eventually re-implemented all the useful ones...
  execCommand: function (cmd, arg) {
    if (this.isFocused()) {
      this.document.execCommand(cmd, false, arg);
      this.checkCursorMove();
      this.checkLiveChange();
    }
  },
  queryCommandState: function (cmd, arg) {
    if (this.isFocused()) {
      return this.document.queryCommandState(cmd, false, arg);
    }
  },
  queryCommandValue: function (cmd, arg) {
    if (this.isFocused()) {
      return this.document.queryCommandValue(cmd, false, arg);
    }
  },
  queryCommandEnabled: function (cmd, arg) {
    if (this.isFocused()) {
      return this.document.queryCommandEnabled(cmd, false, arg);
    }
  },

  // reimplementation of document.execCommand('formatBlock', false, 'x') that behaves more consistently cross browser
  switchToBlock: function (type) {
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
  },

  // reimplementation of document.queryCommandValue('formatBlock', false, 'x') that behaves more consistently cross browser
  isCurrentBlock: function (type) {
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
  },

  getCurrentBlocks: function () {
    var blocks;
    if (! this.isFocused()) {
      return [];
    }
    blocks = $(this.node).find(InlineEditor.TOGGLEABLE_BLOCKS_SELECTOR).not(':has(' + InlineEditor.TOGGLEABLE_BLOCK_CONTAINERS_SELECTOR + ')').filter(function () {
      return InlineEditor.Selection.intersectsNode(this);
    });
    return blocks;
  },
  getCurrentBlocklessContainers: function () {
    var blocks;
    if (! this.isFocused()) {
      return [];
    }
    blocks = $(this.node).find(InlineEditor.TOGGLEABLE_BLOCK_CONTAINERS_SELECTOR).andSelf().not(':has(' + InlineEditor.TOGGLEABLE_BLOCKS_SELECTOR + ')').filter(function () {
      return InlineEditor.Selection.intersectsNode(this);
    });
    return blocks;
  },
  getCurrentBlocklessRanges: function () {
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
  },

  // if a move or change has occurred, trigger the custom 'live_change' and 'cursormove' events
  checkCursorMove: function () {
    var sel = new InlineEditor.Selection(this.document), node = this.node;
    if (sel.anchorNode && sel.intersectsNode(this.node)) {
      if (! sel.equals(this.lastSelection) || node.innerHTML !== this.lastSource) {
        $(node).trigger('cursor_move');
        this.lastSelection = sel;
      }
    } else if (this.lastSelection !== null) {
      $(node).trigger('cursor_move');
      this.lastSelection = null;
    }
  },

  _onSaveSuccess: function() {
    this.lastSource      =
    this.lastSourceSaved = this.node.innerHTML;
  },
  hasUnsavedChanges: function() {
    return (this.node.innerHTML != this.lastSourceSaved);
  },
  save: function() {
    $(this).trigger('save_if_changed');
  },

  // (normal dom 'change' events happen when focus is lost, not live as the change happens)
  checkLiveChange: function() {
    var node = this.node;
    if (node.innerHTML !== this.lastSource) {
      //console.log("node.innerHTML !== this.lastSource");
      //console.log("this.lastSource=", this.lastSource);
      //console.log("node.innerHTML=", node.innerHTML);
      $(node).trigger('live_change');
      this.lastSource = node.innerHTML;
    } else {
      //console.log("node.innerHTML === this.lastSource");
    }
  },

  // Does an Ajax Get request to get the current state of the object from the database
  ajaxGetObject: function(callback) {
    var $this = $(this.node);
    if ($this.data('url')) {
      $.ajax({
        type: 'get',
        url:  $this.data('url'),
        dataType: 'json',
        success: function(data, msg, xhr) {
          callback.call($this, data, msg, xhr);
        },
        error: InlineEditor.defaultAjaxErrorHandler,
      })
    }
  },
});

//--------------------------------------------------------------------------------------------------
// Class methods

$.extend(InlineEditor, {
  // checks if focus is currently on any active InlineEditor-editable object...
  isFocusedEditor: function () {
    var editor = InlineEditor.focusedEditor();
    return !! editor && editor.isEnabled();
  },
  // returns currently focused InlineEditor object instance...
  focusedEditor: function () {
    var focused_elem = window.document.activeElement;
    if (! focused_elem) return null;
    return InlineEditor.getEditorOrParentEditor(focused_elem);
  },
  // returns any editor instance that is attached directly to a given DOM node
  getEditor: function (node) {
    return $(node).data('inlineEditor');
  },
  getEditorOrParentEditor: function (node) {
    var nodes = $(node).parents().andSelf();
    for (var idx = 0; idx < nodes.length; idx++) {
      var editor = InlineEditor.getEditor(nodes.get(idx));
      if (!! editor) return editor;
    }
    return null;
  },

  // restores focus to the InlineEditor editable element that had focus last
  restore_last_focused_element: function() {
    InlineEditor.last_focused_element && InlineEditor.last_focused_element.focus();
  },
  restore_last_selection: function() {
    InlineEditor.last_selection       && InlineEditor.last_selection.restore();
  },
  restore_last_focused_element_and_selection: function() {
    InlineEditor.restore_last_focused_element();
    InlineEditor.restore_last_selection();
  },

  // event handlers to check if custom events should fire
  checkMoveOrChangeHandler: function (evt) {
    var editor = InlineEditor.getEditor(this);
    editor.checkCursorMove();
    editor.checkLiveChange();
  },

  // utility for getting a document object from a variety of objects...
  getDocumentFrom: function (with_what) {
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
  },

  isDocument: function (doc) {
    return doc.documentElement && doc.defaultView;
  },
  isSelection: function (sel) {
    // alert(sel.anchorNode);
    return sel.anchorNode && sel.focusNode;
  },
  isNode: function (node) {
    return node.ownerDocument;
  },

  getOnlyContained: function(selector) {
    var editor = InlineEditor.focusedEditor();
    if (! editor) return null;
    //console.log("window.document.activeElement=", window.document.activeElement);
    var selection = InlineEditor.Selection.getCurrent();
    //console.log("selection=", selection);
    return selection.getOnlyContained($(editor.node), 'img');
  },

  postDataFromInlineEditableElement: function(element) {
    $element = $(element)
    var editor = InlineEditor.getEditor(element);
    return $element.data('object-class').underscore() + '[' + $element.data('attribute') + ']=' +
           encodeURIComponent(editor.node.innerHTML)
  },

  // Compare: defaultSaveHandler, saveMultipleElements
  // options.data: you can pass in additional data to be saved, for example by serializing a form
  // TODO: Maybe make it automatically get url and save-type from the elements that the user wants to save. (That would only work if they were all for the same object and could be sent to the same URL. Although we could theoretically make separate requests for each object that they're trying to save...)
  saveMultipleElements: function(options) {
    var data = '';
    var $this;
    options.elements.each(function () {
      $this = $(this);
      data += '&' + InlineEditor.postDataFromInlineEditableElement(this);
    });
    data += (options.data.match(/^&/) ? '' : '&') + options.data;
    //console.debug("data=", data);
    $this.trigger('saving');

    $.ajax($.extend({
      type: options['save-type'],
      url: options.url,
      dataType: 'json',
      data: data,
      success: options.save_success,
      error: InlineEditor.defaultAjaxErrorHandler,
    }, {}));

  },
});


//--------------------------------------------------------------------------------------------------
// Default event handlers

$.extend(InlineEditor, {

  defaultLiveChangeHandler: function (evt) {
    var $this = $(this), editor = InlineEditor.getEditor(this);
    // trigger the save handler after so many milliseconds of idle time
    if (editor.idleSaveTimeout) {
      clearTimeout(editor.idleSaveTimeout);
    }
    editor.idleSaveTimeout = setTimeout(function () {
      $this.trigger('save_if_changed');
    }, $this.data('idle-save-time'));

    // Whereas save_if_changed isn't triggered until the idle delay, onChange gets triggered immediately...
    var options = editor.getConf();
    options.onChange();
  },

  focusHandler: function (evt) {
    // console.debug('focused:', evt.currentTarget, evt.currentTarget.ownerDocument.activeElement);
    // if (InlineEditor.in_focusHandler) return; // recursion control (the putInNode call below causes this to be called again)
    // InlineEditor.in_focusHandler = true;
    var $this = $(this);
    
    // skip if already focused (the putInNode call below can cause this to be called again)
    if ($this.hasClass($this.data('editing-class'))) return

    // add class that indicates it's currently being edited
    $this.addClass($this.data('editing-class'));

    // hack to fix Safari/Chrome, when moving focus from a form element!
    // The problem with this is that it causes another focus event, which causes this handler to get called again (see the check at top of function).
    InlineEditor.Selection.putInNode(this);

    $this.trigger('custom_focus');
    // InlineEditor.in_focusHandler = false;
  },

  // focus on something inside an editable element (but not the editable element itself)
  subFocusHandler: function (evt) {
    // console.debug('focused:', evt.currentTarget, evt.currentTarget.ownerDocument.activeElement,
    //   evt.currentTarget.ownerDocument.defaultView.getSelection().anchorNode, evt.currentTarget.ownerDocument.defaultView.getSelection().anchorOffset,
    //   evt.currentTarget.ownerDocument.defaultView.getSelection().focusNode, evt.currentTarget.ownerDocument.defaultView.getSelection().focusOffset
    // );
    var node = InlineEditor.getEditorOrParentEditor(evt.currentTarget).node;
    var $node = $(node);
    if ($node.hasClass($node.data('editing-class'))) return;
    $node.addClass($node.data('editing-class'));
    // just in FF: if selection is in parent node, move it to around the child node... other browsers fail the if statement and do nothing
    if (evt.currentTarget.ownerDocument.defaultView.getSelection().anchorNode == node)
      new InlineEditor.Selection(evt.currentTarget);
    $node.trigger('custom_focus');
  },
  subBlurHandler: function (evt) {
    // console.debug('blured:', evt.currentTarget, evt.currentTarget.ownerDocument.activeElement, evt.currentTarget.ownerDocument.defaultView.getSelection().anchorNode, evt.currentTarget.ownerDocument.defaultView.getSelection().focusNode);
    var $this = $(InlineEditor.getEditorOrParentEditor(evt.currentTarget).node);
    if (! $this.hasClass($this.data('editing-class'))) return;
    $this.removeClass($this.data('editing-class'));
  },

  defaultBlurHandler: function (evt) {
    // console.debug('blured:', evt.currentTarget, evt.currentTarget.ownerDocument.activeElement);
    var $this = $(this), editor = InlineEditor.getEditor(this);
    // remove class that indicates it's currently being edited
    $this.removeClass($this.data('editing-class'));
    // remove the save timeout, and trigger the custom save event
    if (editor.idleSaveTimeout) {
      clearTimeout(editor.idleSaveTimeout);
      editor.idleSaveTimeout = null;
    }
    $this.trigger('save_if_changed');
  },

  saveIfChanged: function (evt) {
    var editor = InlineEditor.getEditor(this);
    if (editor.hasUnsavedChanges()) {
      //console.log("editor.node.innerHTML (changed  )=", editor.node.innerHTML);
      $(this).trigger('save');
    } else {
      //console.log("don't need to save (content is the same as last time we saved)")
      //console.log("editor.node.innerHTML (unchanged)=", editor.node.innerHTML);
    };
  },

  focusout: function (evt) {
    //console.log('focusout for', this);
    InlineEditor.last_focused_element = this;
    InlineEditor.last_selection = new InlineEditor.Selection(this.document);
  },

  // Compare: defaultSaveHandler, saveMultipleElements
  defaultSaveHandler: function(evt) {
    //var data = '_method=put';
    var data = '';
    var $this = $(this);

    var e = $.Event('onBeforeSave');
    $this.trigger(e);
    if (e.isDefaultPrevented()) { return this; }

    console.log('defaultSaveHandler: saving')
    var editor = InlineEditor.getEditor(this);

    if ($this.data('url')) {
      data += '&' + InlineEditor.postDataFromInlineEditableElement(this);
      var type = $this.data('save-type') || $this.data('object-id') ? 'PUT' : 'POST';
      $.ajax($.extend({
        type: type,
        url:  $this.data('url'),
        dataType: 'json',
        data: data,
        success: function(data, msg, xhr) {
          editor._onSaveSuccess();
          $this.trigger('save_success', [data, msg, xhr]);
        },
        error:   function(xhr,  msg, err) {
          $this.trigger('save_error', [xhr, msg, err]);
        },
      }, $this.data('ajax-options')));

      $this.trigger('saving');
    }
  },

  defaultAjaxErrorHandler: function(event, xhr, msg, err) {
    //console.log("arguments=", arguments);
    if (typeof msg != "undefined" && msg != "error" && err != "undefined") {
      alert("defaultAjaxErrorHandler:\n'" + msg + "'\n'" + err + "'");
    }
  },
});


//--------------------------------------------------------------------------------------------------
// Class attributes

$.extend(InlineEditor, {
  last_focused_element: null,
  last_selection: null,
  //in_focusHandler: false,

});

InlineEditor.SUB_FOCUSABLE_TYPES = ['video', 'audio', 'iframe', 'object'];
InlineEditor.SUB_FOCUSABLE_SELECTOR = InlineEditor.SUB_FOCUSABLE_TYPES.join(', ');

// Innards of getCurrentBlocks/getCurrentBlocklessContainers.
// Need to find a proper home for it, it feels like cruft laying here...
// As we reimplement more of the built-in execCommand things for cross browser consistency, proper structure should become clear...
InlineEditor.TOGGLEABLE_BLOCK_TYPES = ['address', 'div', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'p', 'pre'];
InlineEditor.TOGGLEABLE_BLOCK_CONTAINER_TYPES = ['blockquote', 'dd', 'dt', 'li', 'td', 'th'];
InlineEditor.ALL_BLOCK_TYPES = ['address', 'blockquote', 'dd', 'div', 'dl', 'dt', 'form', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'li', 'ol', 'p', 'pre', 'table', 'tbody', 'td', 'tfoot', 'th', 'thead', 'tr', 'ul'];
InlineEditor.TOGGLEABLE_BLOCKS_SELECTOR = InlineEditor.TOGGLEABLE_BLOCK_TYPES.join(', ');
InlineEditor.TOGGLEABLE_BLOCK_CONTAINERS_SELECTOR = InlineEditor.TOGGLEABLE_BLOCK_CONTAINER_TYPES.join(', ');

InlineEditor.DEFAULT_OPTIONS = {
  'editing-class': 'editing',
  'idle-save-time': 3000, // milliseconds
  //'save-type': 'POST',
  focus:        null,
  blur:         InlineEditor.defaultBlurHandler,
  liveChange:   InlineEditor.defaultLiveChangeHandler,
  save:         InlineEditor.defaultSaveHandler,
  saveError:    InlineEditor.defaultAjaxErrorHandler,
  onChange:     null,
};

//==================================================================================================
// InlineEditor.Element
// --------------------
// 
// Adds functionality not found in various typical DOM element objects.
// 

// constructor using a DOM Node, or a tag name string and optional Document
// one of either DOM Node or tag name string is required.
InlineEditor.Element = function (node, doc) {
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

$.extend(InlineEditor.Element.prototype, {
  // changes element to indicated element type, preserving selection, attributes, and contents
  changeTypeSafe: function (type) {
    var elem = new InlineEditor.Element(type);
    $(this.node.attributes).each(function () {
      $(elem.node).attr(this.name, this.value);
    });
    this.replaceWithSafe(elem);
  },

  // wraps element contents with indicated element type, preserving selection and contents
  wrapContentsWithTypeSafe: function (type) {
    this.wrapContentsSafe(new InlineEditor.Element(type));
  },

  // changes element to indicated InlineEditor.Element, preserving selection and contents
  replaceWithSafe: function (elem) {
    var sel = InlineEditor.Selection.newForReplacingElement(this, elem);
    new InlineEditor.Range(this.document).replaceElementWithElement(this, elem);
    sel.restore();
  },

  // wraps element contents with indicated InlineEditor.Element, preserving selection and contents
  wrapContentsSafe: function (elem) {
    var sel = InlineEditor.Selection.newForReplacingElement(this, elem);
    new InlineEditor.Range(this.document).wrapElementContentsWithElement(this, elem);
    sel.restore();
  },
});

//==================================================================================================
// InlineEditor.Range
// --------------------
// 
// Handles ranges of text/tags (including partial elements) in a cross-browser way
// Adds additional functionality not in the standard DOM Range object.
// 

// Constructor using optional indicated native Range, or a new one with indicated Document, or window.document
InlineEditor.Range = function (with_what, to_what) {
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

$.extend(InlineEditor.Range.prototype, {

  // wraps current InlineEditor.Range with indicated element type, preserving selection and contents
  wrapWithTypeSafe: function (type) {
    this.wrapWithElementSafe(new InlineEditor.Element(type));
  },
  // wraps current InlineEditor.Range with indicated InlineEditor.Element, preserving selection and contents
  wrapWithElementSafe: function (elem) {
    var sel = new InlineEditor.Selection(this.document);
    this.wrapWithElement(elem);
    sel.restore();
  },

  // replaces an InlineEditor.Element with another, using ranges
  replaceElementWithElement: function (old_elem, new_elem) {
    var contents = this.extractElementContentNodes(old_elem);
    this.deleteElementAndContents(old_elem);
    this.insertElement(new_elem, contents);
  },
  // wraps contents of an InlineEditor.Element with indicated InlineEditor.Element, using ranges
  wrapElementContentsWithElement: function (old_elem, new_elem) {
    this.insertElement(new_elem, this.extractElementContentNodes(old_elem));
  },
  // wraps current InlineEditor.Range with indicated InlineEditor.Element
  wrapWithElement: function (elem) {
    this.insertElement(elem, this.range.extractContents());
  },

  // selects, extracts (removes), and returns contents of indicated InlineEditor.Element
  extractElementContentNodes: function (elem) {
    this.selectElementContents(elem);
    return this.range.extractContents();
  },
  // selects and deletes indicated InlineEditor.Element, and any contents it may contain
  deleteElementAndContents: function (elem) {
    this.select(elem);
    this.range.deleteContents();
  },

  // insert InlineEditor.Element at beginning of current InlineEditor.Range, optionally populating it with given content node(s)
  insertElement: function (elem, contents) {
    this.range.insertNode(elem.node);
    if (contents) {
      this.selectElementContents(elem);
      this.range.insertNode(contents);
    }
  },

  // when given one arg: selects a given InlineEditor.Element, Selection, or DOM Node with current range
  // when given two args: selects area inclusively between two InlineEditor.Element objects, Nodes, or Selections
  select: function (with_what, to_what) {
    if (with_what.anchorNode) {
      this.range.setStart(with_what.anchorNode, with_what.anchorOffset);
    } else {
      this.range.setStartBefore(with_what.isInlineEditorElement ? with_what.node : with_what);
    }
    if (! to_what) {
      to_what = with_what;
    }
    if (to_what.focusNode) {
      this.range.setEnd(to_what.focusNode, to_what.focusOffset);
    } else {
      this.range.setEndAfter(to_what.isInlineEditorElement ? to_what.node : to_what);
    }
  },
  // selects a given DOM Node with current range
  selectNode: function (node) {
    try {
      this.range.selectNode(node);
    } catch (e) {
      this.range.selectNodeContents(node);
    }
  },
  // selects the contents of an InlineEditor.Element with current range
  selectElementContents: function (elem) {
    this.selectNodeContents(elem.node);
  },
  // selects the contents of a DOM Node with current range
  selectNodeContents: function (node) {
    this.range.selectNodeContents(node);
  },

  // tests if current range intersects an InlineEditor.Element
  intersectsElement: function (elem) {
    return this.intersectsNode(elem.node);
  },
  // tests if current range intersects a DOM Node
  intersectsNode: function (node) {
    // some browsers have this built in (FF<=2)
    if (this.range.intersectsNode) {
      return this.range.intersectsNode(node);
    } else {
      // otherwise emulate it with a second range (FF>=3, IE9)
      return this.intersectsRange(new InlineEditor.Range(node));
    }
  },
  // tests if current range intersects another InlineEditor.Range
  intersectsRange: function (range) {
    return this.range.compareBoundaryPoints(Range.END_TO_START, range.range) === -1 &&
           this.range.compareBoundaryPoints(Range.START_TO_END, range.range) ===  1;
  },

  // tests if two range instances point to an identical area
  equals: function (range) {
    return !!range && // this.range == range.range;
      this.range.startContainer === range.range.startContainer && this.range.startOffset === range.range.startOffset &&
      this.range.endContainer   === range.range.endContainer   && this.range.endOffset   === range.range.endOffset;
  },

  // In Chrome and Firefox,
  // when you select an image from left to right, it reports endOffset as 2
  // when you select an image from right to left, it reports endOffset as 1
  // But they're the same selection! So if you want to account for that idiosyncrasy and still consider those 2 range objects as equal, you can use this function instead of equals().
  approxEquals: function (range) {
    //console.log("this.range.startContainer === range.range.startContainer=", this.range.startContainer === range.range.startContainer, this.range.startContainer, range.range.startContainer);
    //console.log("this.range.endContainer   === range.range.endContainer=",   this.range.endContainer   === range.range.endContainer,   this.range.endContainer, range.range.endContainer);
    //console.log("this.range.startOffset === range.range.startOffset=", this.range.startOffset, range.range.startOffset);
    //console.log("this.range.endOffset === range.range.endOffset=", this.range.endOffset, range.range.endOffset);
    return !!range &&
      this.range.startContainer === range.range.startContainer && this.range.startOffset === range.range.startOffset &&
      this.range.endContainer   === range.range.endContainer   && Math.abs(this.range.endOffset - range.range.endOffset) <= 1;
  },

  // Searches nodes contained in selection for the selector. If it matches exactly once, return it. Otherwise returns null.
  getOnlyContained: function(container, selector) {
    var self = this;
    var matches = container.find(selector).filter(function () {
      return self.approxEquals(new InlineEditor.Range(this));
    });
    return matches.length > 0 ? matches.get(0) : null;
  },
});

//--------------------------------------------------------------------------------------------------

$.extend(InlineEditor.Range, {
  // checks if given argument can be selected with new InlineEditor.Range().select()
  isSelectable: function (with_what) {
    return (with_what && with_what.anchorNode && with_what.focusNode) ||
      (with_what && with_what.isInlineEditorElement) ||
      (with_what && InlineEditor.isNode(with_what) && ! InlineEditor.isDocument(with_what));
  },
});



//==================================================================================================
// InlineEditor.Selection
// --------------------
// 
// Handles a selected area in a cross-browser way (does not support IE<=8)
// There is no real standard definition of a Selection object yet, so browsers naturally are inconsistent.
// 
// An instance of this object behaves very differently from the usual browser built-in Selection one
// in that it represents a 'snapshot' of what was selected when it was originally instantiated
// and does not change or become invalid as the document state or cursor position changes...
// 
// Methods that examine or use the real current position are therefore class methods not instance methods
// (although those that manipulate the real position in relation to a snapshot are instance ones of course)
// 

// constructor takes an optional window object to base the selection on
InlineEditor.Selection = function (with_what) {
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
  } else if (InlineEditor.isNode(with_what)){
    this.document = with_what.ownerDocument;
    this.window = this.document.defaultView;
    sel = this.window.getSelection();
    var range = this.document.createRange();
    range.selectNode(with_what);
    sel.addRange(range);
  } else {
    throw 'bad parameter for InlineEditor.Selection contructor';
  }
  this.anchorNode   = sel.anchorNode;
  this.anchorOffset = sel.anchorOffset;
  this.focusNode    = sel.focusNode;
  this.focusOffset  = sel.focusOffset;
  this.isInlineEditorSelection = true;
};

$.extend(InlineEditor.Selection.prototype, {
  // tests if selection intersects indicated InlineEditor.Element
  intersectsElement: function (elem) {
    return this.intersectsNode(elem.node);
  },

  // tests if selection intersects indicated DOM Node
  // some browsers like FF have an optimization for the current-selection version (Opera claims to have it, but it doesn't function!!)
  intersectsNode: function (node) {
    return new InlineEditor.Range(this).intersectsNode(node);
  },

  // tests if selection intersects indicated InlineEditor.Range
  intersectsRange: function (range) {
    return new InlineEditor.Range(this).intersectsRange(range);
  },

  // change this selection to be in relation to a new node about to be inserted where an old node exists
  // use when replacing the node, or putting a new node inside the old node spanning its entire contents
  // this way the selection will still be valid after the change is made
  updateForReplacingElement: function (old_elem, new_elem) {
    this.updateForReplacingNode(old_elem.node, new_elem.node);
  },
  updateForReplacingNode: function (old_node, new_node) {
    if (this.anchorNode === old_node) {
      this.anchorNode = new_node;
    }
    if (this.focusNode  === old_node) {
      this.focusNode  = new_node;
    }
  },

  // reposition caret or reselect saved selection
  restore: function () {
    if (! this.anchorNode) return;
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
  },

  // tests if two selection area instances point to an identical area
  equals: function (sel) {
    return !! sel &&
      this.anchorNode === sel.anchorNode && this.anchorOffset === sel.anchorOffset &&
      this.focusNode  === sel.focusNode  && this.focusOffset  === sel.focusOffset;
  },
});

$.extend(InlineEditor.Selection, {
  intersectsNode: function (node) {
    var sel = node.ownerDocument.defaultView.getSelection();
    return sel.containsNode && ! navigator.userAgent.match(/Opera/) ? sel.containsNode(node, true) : new InlineEditor.Range(sel).intersectsNode(node);
  },
  intersectsRange: function (range) {
    return new InlineEditor.Range(range.window.getSelection()).intersectsRange(range);
  },

  // Saf/Chr will not properly put the cursor inside a contentEditable element, if you are moving focus from a form element!
  // this fixes that (and does nothing if it wasn't broken), call it from the onfocus event to fix it
  // algorithm: if cursor seems to be nowhere, put it at the beginning of the indicated node
  putInNode: function (node) {
    var sel = window.getSelection();
    if (! sel.anchorNode) {
      sel.collapse(node, 0);
    }
  },

  // Document: how is this different from this.document.createRange()?
  getCurrent: function() {
    return new InlineEditor.Range(new InlineEditor.Selection(window.document));
  },

  newForReplacingElement: function (old_elem, new_elem) {
    return InlineEditor.Selection.newForReplacingNode(old_elem.node, new_elem.node);
  },
  newForReplacingNode: function (old_node, new_node) {
    var sel = new InlineEditor.Selection(old_node.ownerDocument);
    sel.updateForReplacingNode(old_node, new_node);
    return sel;
  },

});

//==================================================================================================
// Misc

// no-op if console logger doesn't exist, so that errors aren't thrown
// this can be commented out if all debugging is commented out...
if (! window.console) {
  window.console = {
    log: function () {},
    debug: function () {}
  }
}

$.extend(String.prototype, {
  // (Ported from activesupport)
  //    'K3cms::S3Podcast::Episode'.underscore()
  // => "k3cms/s3_podcast/episode"
  underscore: function(){
    word = String(this)
    word = word.replace(/::/g, '/')
    word = word.replace(/([A-Z]+)([A-Z][a-z])/g, "$1_$2")
    word = word.replace(/([a-z\d])([A-Z])/g,     "$1_$2")
    word = word.replace(/-/g, "_")
    word = word.toLowerCase();
    return word
  }
})

//==================================================================================================
