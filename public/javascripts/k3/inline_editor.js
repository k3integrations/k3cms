//==================================================================================================
if (typeof(RestInPlaceEditor) != 'undefined' && RestInPlaceEditor.forms) {
  RestInPlaceEditor.forms = $.extend(RestInPlaceEditor.forms, {
    inline_editor : {
      activateForm : function() {
      },
      
      getValue : function() {
        var value = InlineEditor.getEditor(this.element).lastSource
        //console.log('getValue:', value)
        return value;
      },

      saving : function(event) {
        $('#last_saved_status').html('Saving...');
      },

      success : function(event) {
        $('#last_saved_status').html('Saved seconds ago');
      },
    }
  })
}

//==================================================================================================
// label text, css class, inline/block, command to do functionality, command to check state, command to check if enabled, args to pass commands
toolbar_options = [
  ['B',         'toggleBold',             true,  'execCommand', 'queryCommandState', 'queryCommandEnabled', ['bold']],
  ['I',         'toggleItalic',           true,  'execCommand', 'queryCommandState', 'queryCommandEnabled', ['italic']],
  ['U',         'toggleUnderline',        true,  'execCommand', 'queryCommandState', 'queryCommandEnabled', ['underline']],
  ['S',         'toggleStrikethrough',    true,  'execCommand', 'queryCommandState', 'queryCommandEnabled', ['strikeThrough']],
  ['<sup>sup</sup>', 'toggleSuperscript', true,  'execCommand', 'queryCommandState', 'queryCommandEnabled', ['superscript']],
  ['<sub>sub</sub>', 'toggleSubscript',   true,  'execCommand', 'queryCommandState', 'queryCommandEnabled', ['subscript']],
  ['OL',        'insertOrderedList',      false, 'execCommand', 'queryCommandState', 'queryCommandEnabled', ['insertOrderedList']],
  ['UL',        'insertUnorderedList',    false, 'execCommand', 'queryCommandState', 'queryCommandEnabled', ['insertUnorderedList']],
  ['In',        'indent',                 false, 'execCommand',  false,              'queryCommandEnabled', ['indent']],
  ['Out',       'outdent',                false, 'execCommand',  false,              'queryCommandEnabled', ['outdent']],
  ['Left',      'justifyLeft',            false, 'execCommand', 'queryCommandState', 'queryCommandEnabled', ['justifyLeft']],
  ['Center',    'justifyCenter',          false, 'execCommand', 'queryCommandState', 'queryCommandEnabled', ['justifyCenter']],
  ['Right',     'justifyRight',           false, 'execCommand', 'queryCommandState', 'queryCommandEnabled', ['justifyRight']],
  // ['P',      'blockParagraph',         false, 'execCommand', 'queryCommandState', 'queryCommandEnabled', ['insertParagraph']],
  // ['P',      'blockParagraph',         false, 'execCommand', 'queryCommandValue', 'queryCommandEnabled', ['formatBlock', 'p']],
  // ['Pre',    'blockPre',               false, 'execCommand', 'queryCommandValue', 'queryCommandEnabled', ['formatBlock', 'pre']],
  // ['Address','blockAddress',           false, 'execCommand', 'queryCommandValue', 'queryCommandEnabled', ['formatBlock', 'address']],
  // ['H1',     'blockH1',                false, 'execCommand', 'queryCommandValue', 'queryCommandEnabled', ['formatBlock', 'h1']],
  // ['H2',     'blockH2',                false, 'execCommand', 'queryCommandValue', 'queryCommandEnabled', ['formatBlock', 'h2']],
  // ['H3',     'blockH3',                false, 'execCommand', 'queryCommandValue', 'queryCommandEnabled', ['formatBlock', 'h3']],
  // ['H4',     'blockH4',                false, 'execCommand', 'queryCommandValue', 'queryCommandEnabled', ['formatBlock', 'h4']],
  // ['H5',     'blockH5',                false, 'execCommand', 'queryCommandValue', 'queryCommandEnabled', ['formatBlock', 'h5']],
  // ['H6',     'blockH6',                false, 'execCommand', 'queryCommandValue', 'queryCommandEnabled', ['formatBlock', 'h6']]
  ['Plain',     'blockDiv',               false, 'switchToBlock', 'isCurrentBlock',   false,                ['div']],
  ['Paragraph', 'blockP',                 false, 'switchToBlock', 'isCurrentBlock',   false,                ['p']],
  ['Preformatted', 'blockPre',            false, 'switchToBlock', 'isCurrentBlock',   false,                ['pre']],
  ['Address',   'blockAddress',           false, 'switchToBlock', 'isCurrentBlock',   false,                ['address']],
  ['Heading 1', 'blockH1',                false, 'switchToBlock', 'isCurrentBlock',   false,                ['h1']],
  ['Heading 2', 'blockH2',                false, 'switchToBlock', 'isCurrentBlock',   false,                ['h2']],
  ['Heading 3', 'blockH3',                false, 'switchToBlock', 'isCurrentBlock',   false,                ['h3']],
  ['Heading 4', 'blockH4',                false, 'switchToBlock', 'isCurrentBlock',   false,                ['h4']],
  ['Heading 5', 'blockH5',                false, 'switchToBlock', 'isCurrentBlock',   false,                ['h5']],
  ['Heading 6', 'blockH6',                false, 'switchToBlock', 'isCurrentBlock',   false,                ['h6']]
];

var structured_toolbar_options = [];
$(toolbar_options).each(function (i) {
  option = {
    label:             this[0],
    klass:             this[1],
    is_inline:         this[2],
    editor_cmd:        this[3],
    query_state_cmd:   this[4],
    query_enabled_cmd: this[5],
    cmd_args:          this[6],
  };
  structured_toolbar_options = $.merge(structured_toolbar_options, [option]);
});
toolbar_options = structured_toolbar_options;

  
//==================================================================================================
function initInlineEditor(options) {
  $('.editable').inlineEditor(options);

  // inline_editor handles enabling contentEditable, etc.
  // We just tell inline_editor to come back and call our saveHandler whenever a save is triggered (blur or livechange)
  // Now that it's initialized, configure the inline_editor with rest_in_place callbacks to handle saving
  jQuery(".editable").rest_in_place();
  $('.editable').inlineEditor({
    saveHandler:     function(event) {
      //console.log('saveHandler')
      //console.log("$(this).data()=", $(this).data());

    //var klass;
    //if ($(this).data('object') == 'k3_page') {
    //  klass = Pages;
    //}
    //// Or should this be Ribbon.update_last_saved_status(klass.get_last_saved_status(...))?
    //klass.update_last_saved_status({
    //  url:       $(this).data('url'),
    //  attribute: $(this).data('attribute'),
    //});

      $(this).data('restInPlaceEditor').update();
    },
  });


  $ribbon = $('#ribbon .row_2')
  if ($ribbon.length == 0)
    $ribbon = $('#ribbon')
  
  // show initial toolbar button layout, according to table at top
  $(toolbar_options).each(function (index) {
    var elem = document.createElement('li');
    $(elem).addClass(this.klass);
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
    $ribbon.find('.' + this.klass).mousedown(function (event) {
      var editor = InlineEditor.focusedEditor();
      // ignore button presses if no editable area is selected (you can also use InlineEditor.isFocusedEditor())
      if (! editor || ! editor.isEnabled()) {
        return false;
      }
      // execute the command
      if (! $(this).hasClass('disabled')) {
        editor[self.editor_cmd](self.cmd_args[0], self.cmd_args[1]);
      }
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
}

// refreshing toolbar button classes to show toggled/disabled states, depending on where the cursor currently is
function refreshButtons() {
  var editable_active = InlineEditor.isFocusedEditor();
  $(toolbar_options).each(function (index) {
    var btn = $('#ribbon .' + this.klass);
    if (! editable_active) {
      btn.addClass('disabled');
    } else {
      var ined = InlineEditor.focusedEditor();
      if (! ined.isInline() || this.is_inline) {
        if (this.query_state_cmd) {
          ined[this.query_state_cmd](this.cmd_args[0], this.cmd_args[1]) ? btn.addClass('toggledOn') : btn.removeClass('toggledOn');
        }
        if (this.query_enabled_cmd) {
          ined[this.query_enabled_cmd](this.cmd_args[0], this.cmd_args[1]) ? btn.removeClass('disabled') : btn.addClass('disabled');
        } else {
          btn.removeClass('disabled');
        }
      } else {
        btn.addClass('disabled');
      }
    }
  });
}


