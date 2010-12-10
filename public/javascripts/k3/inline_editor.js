// label text, css class, command to do functionality, command to check state, command to check if enabled, args to pass commands
toolbar_options = [
  ['B',         'toggleBold',             'execCommand', 'queryCommandState', 'queryCommandEnabled', ['bold']],
  ['I',         'toggleItalic',           'execCommand', 'queryCommandState', 'queryCommandEnabled', ['italic']],
  ['U',         'toggleUnderline',        'execCommand', 'queryCommandState', 'queryCommandEnabled', ['underline']],
  ['S',         'toggleStrikethrough',    'execCommand', 'queryCommandState', 'queryCommandEnabled', ['strikeThrough']],
  ['<sup>sup</sup>', 'toggleSuperscript', 'execCommand', 'queryCommandState', 'queryCommandEnabled', ['superscript']],
  ['<sub>sub</sub>', 'toggleSubscript',   'execCommand', 'queryCommandState', 'queryCommandEnabled', ['subscript']],
  ['OL',        'insertOrderedList',      'execCommand', 'queryCommandState', 'queryCommandEnabled', ['insertOrderedList']],
  ['UL',        'insertUnorderedList',    'execCommand', 'queryCommandState', 'queryCommandEnabled', ['insertUnorderedList']],
  ['In',        'indent',                 'execCommand',  false,              'queryCommandEnabled', ['indent']],
  ['Out',       'outdent',                'execCommand',  false,              'queryCommandEnabled', ['outdent']],
  ['Left',      'justifyLeft',            'execCommand', 'queryCommandState', 'queryCommandEnabled', ['justifyLeft']],
  ['Center',    'justifyCenter',          'execCommand', 'queryCommandState', 'queryCommandEnabled', ['justifyCenter']],
  ['Right',     'justifyRight',           'execCommand', 'queryCommandState', 'queryCommandEnabled', ['justifyRight']],
  // ['P',      'blockParagraph',         'execCommand', 'queryCommandState', 'queryCommandEnabled', ['insertParagraph']],
  // ['P',      'blockParagraph',         'execCommand', 'queryCommandValue', 'queryCommandEnabled', ['formatBlock', 'p']],
  // ['Pre',    'blockPre',               'execCommand', 'queryCommandValue', 'queryCommandEnabled', ['formatBlock', 'pre']],
  // ['Address','blockAddress',           'execCommand', 'queryCommandValue', 'queryCommandEnabled', ['formatBlock', 'address']],
  // ['H1',     'blockH1',                'execCommand', 'queryCommandValue', 'queryCommandEnabled', ['formatBlock', 'h1']],
  // ['H2',     'blockH2',                'execCommand', 'queryCommandValue', 'queryCommandEnabled', ['formatBlock', 'h2']],
  // ['H3',     'blockH3',                'execCommand', 'queryCommandValue', 'queryCommandEnabled', ['formatBlock', 'h3']],
  // ['H4',     'blockH4',                'execCommand', 'queryCommandValue', 'queryCommandEnabled', ['formatBlock', 'h4']],
  // ['H5',     'blockH5',                'execCommand', 'queryCommandValue', 'queryCommandEnabled', ['formatBlock', 'h5']],
  // ['H6',     'blockH6',                'execCommand', 'queryCommandValue', 'queryCommandEnabled', ['formatBlock', 'h6']]
  ['Plain',     'blockDiv',               'switchToBlock', 'isCurrentBlock',   false,                ['div']],
  ['Paragraph', 'blockP',                 'switchToBlock', 'isCurrentBlock',   false,                ['p']],
  ['Preformatted', 'blockPre',            'switchToBlock', 'isCurrentBlock',   false,                ['pre']],
  ['Address',   'blockAddress',           'switchToBlock', 'isCurrentBlock',   false,                ['address']],
  ['Heading 1', 'blockH1',                'switchToBlock', 'isCurrentBlock',   false,                ['h1']],
  ['Heading 2', 'blockH2',                'switchToBlock', 'isCurrentBlock',   false,                ['h2']],
  ['Heading 3', 'blockH3',                'switchToBlock', 'isCurrentBlock',   false,                ['h3']],
  ['Heading 4', 'blockH4',                'switchToBlock', 'isCurrentBlock',   false,                ['h4']],
  ['Heading 5', 'blockH5',                'switchToBlock', 'isCurrentBlock',   false,                ['h5']],
  ['Heading 6', 'blockH6',                'switchToBlock', 'isCurrentBlock',   false,                ['h6']]
];

var structured_toolbar_options = [];
$(toolbar_options).each(function (i) {
  option = {
    label:             this[0],
    class:             this[1],
    editor_cmd:        this[2],
    query_state_cmd:   this[3],
    query_enabled_cmd: this[4],
    cmd_args:          this[5],
  };
  structured_toolbar_options = $.merge(structured_toolbar_options, [option]);
});
toolbar_options = structured_toolbar_options;

  
function initEditor() {
  $('.editable').inlineEditor();

  $ribbon = $('#ribbon')
  
  // show initial toolbar button layout, according to table at top
  $(toolbar_options).each(function (index) {
    var elem = document.createElement('li');
    $(elem).addClass(this.class);
    $(elem).addClass('button');
    elem.innerHTML = this.label;
    $ribbon.append(elem);
  });
  
  // set initial toolbar button state, and set handler to keep up to date
  refreshButtons();
  $('.editable').bind('cursormove', function (event) {
    refreshButtons();
  });
  
  // toolbar button command handlers
  $(toolbar_options).each(function (index) {
    var self = this;
    $ribbon.find('.' + this.class).mousedown(function (event) {
      var editor = InlineEditor.focusedEditor();
      // ignore button presses if no editable area is selected (you can also use InlineEditor.isFocusedEditor())
      if (! editor || ! editor.isEnabled()) {
        return false;
      }
      // execute the command
      editor[self.editor_cmd](self.cmd_args[0], self.cmd_args[1]); // executes command here!
      // refresh button state
      refreshButtons();
      // returning false doesn't cancel losing editor focus in IE, here's a nasty hacky fix!
      if (navigator.userAgent.match(/MSIE/)) {
        $(editor.node).one('blur', function () {
          this.focus();
        });
      }
      return false;
    });
  });
  
  if (typeof Pages != 'undefined') { 
    $('.editable').bind('blur', function (event) {
      console.log('blur');
      //PagesSerialize()
    });
  }
}

// refreshing toolbar button classes to show toggled/disabled states, depending on where the cursor currently is
function refreshButtons() {
  var editable_active = InlineEditor.isFocusedEditor();
  $(toolbar_options).each(function (index) {
    var btn = $('#ribbon .' + this.class);
    if (! editable_active) {
      btn.addClass('disabled');
    } else {
      var ined = InlineEditor.focusedEditor();
      if (this.query_state_cmd) {
        ined[this.query_state_cmd](this.cmd_args[0], this.cmd_args[1]) ? btn.addClass('toggledOn') : btn.removeClass('toggledOn');
      }
      if (this.query_enabled_cmd) {
        ined[this.query_enabled_cmd](this.cmd_args[0], this.cmd_args[1]) ? btn.removeClass('disabled') : btn.addClass('disabled');
      } else {
        btn.removeClass('disabled');
      }
    }
  });
}


