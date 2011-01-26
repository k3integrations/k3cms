
//==================================================================================================
// label text         | css class             | command to do functionality       | command to check if enabled
//                              | inline/block |             | command to check state                    | args to pass commands
toolbar_options = [
  ['Bold',             'strong',         true,  'execCommand', 'queryCommandState', 'queryCommandEnabled', ['bold']],
  ['Italic',           'emphasis',       true,  'execCommand', 'queryCommandState', 'queryCommandEnabled', ['italic']],
  ['Underline',        'underline',      true,  'execCommand', 'queryCommandState', 'queryCommandEnabled', ['underline']],
  ['Strikethrough',    'strikethrough',  true,  'execCommand', 'queryCommandState', 'queryCommandEnabled', ['strikeThrough']],
  ['Superscript',      'superscript',    true,  'execCommand', 'queryCommandState', 'queryCommandEnabled', ['superscript']],
  ['Subscript',        'subscript',      true,  'execCommand', 'queryCommandState', 'queryCommandEnabled', ['subscript']],
  ['Ordered list',     'ordered_list',   false, 'execCommand', 'queryCommandState', 'queryCommandEnabled', ['insertOrderedList']],
  ['Unordered list',   'unordered_list', false, 'execCommand', 'queryCommandState', 'queryCommandEnabled', ['insertUnorderedList']],
  ['Outdent',          'outdent',        false, 'execCommand',  false,              'queryCommandEnabled', ['outdent']],
  ['Indent',           'indent',         false, 'execCommand',  false,              'queryCommandEnabled', ['indent']],
  ['Align Left',       'align_left',     false, 'execCommand', 'queryCommandState', 'queryCommandEnabled', ['justifyLeft']],
  ['Align Center',     'align_center',   false, 'execCommand', 'queryCommandState', 'queryCommandEnabled', ['justifyCenter']],
  ['Align Right',      'align_right',    false, 'execCommand', 'queryCommandState', 'queryCommandEnabled', ['justifyRight']],
  ['Insert/edit link', 'link',           true,  'execCommand',  false,              'queryCommandEnabled', ['createLink', function(){return prompt('Enter URL:')}]],
  ['Remove link',      'unlink',         true,  'execCommand', 'queryCommandState', 'queryCommandEnabled', ['unlink']],
  ['Insert Image',     'image',          false, 'execCommand',  false,              'queryCommandEnabled', ['insertImage', function(){return prompt('Enter URL:')}]],
  ['Insert Video',     'video',          false,  handleVideo,   false,              false],
  // ['P',             'blockParagraph', false, 'execCommand', 'queryCommandState', 'queryCommandEnabled', ['insertParagraph']],
  // ['P',             'blockParagraph', false, 'execCommand', 'queryCommandValue', 'queryCommandEnabled', ['formatBlock', 'p']],
  // ['Pre',           'blockPre',       false, 'execCommand', 'queryCommandValue', 'queryCommandEnabled', ['formatBlock', 'pre']],
  // ['Address',       'blockAddress',   false, 'execCommand', 'queryCommandValue', 'queryCommandEnabled', ['formatBlock', 'address']],
  // ['H1',            'blockH1',        false, 'execCommand', 'queryCommandValue', 'queryCommandEnabled', ['formatBlock', 'h1']],
  // ['H2',            'blockH2',        false, 'execCommand', 'queryCommandValue', 'queryCommandEnabled', ['formatBlock', 'h2']],
  // ['H3',            'blockH3',        false, 'execCommand', 'queryCommandValue', 'queryCommandEnabled', ['formatBlock', 'h3']],
  // ['H4',            'blockH4',        false, 'execCommand', 'queryCommandValue', 'queryCommandEnabled', ['formatBlock', 'h4']],
  // ['H5',            'blockH5',        false, 'execCommand', 'queryCommandValue', 'queryCommandEnabled', ['formatBlock', 'h5']],
  // ['H6',            'blockH6',        false, 'execCommand', 'queryCommandValue', 'queryCommandEnabled', ['formatBlock', 'h6']]
  ['Plain',            'blockDiv',       false, 'switchToBlock', 'isCurrentBlock',   false,                ['div']],
  ['Paragraph',        'blockP',         false, 'switchToBlock', 'isCurrentBlock',   false,                ['p']],
  //['Preformatted',   'blockPre',       false, 'switchToBlock', 'isCurrentBlock',   false,                ['pre']],
  //['Address',        'blockAddress',   false, 'switchToBlock', 'isCurrentBlock',   false,                ['address']],
  ['Heading 1',        'blockH1',        false, 'switchToBlock', 'isCurrentBlock',   false,                ['h1']],
  ['Heading 2',        'blockH2',        false, 'switchToBlock', 'isCurrentBlock',   false,                ['h2']],
  ['Heading 3',        'blockH3',        false, 'switchToBlock', 'isCurrentBlock',   false,                ['h3']],
  ['Heading 4',        'blockH4',        false, 'switchToBlock', 'isCurrentBlock',   false,                ['h4']],
  ['Heading 5',        'blockH5',        false, 'switchToBlock', 'isCurrentBlock',   false,                ['h5']],
  ['Heading 6',        'blockH6',        false, 'switchToBlock', 'isCurrentBlock',   false,                ['h6']]
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
// See http://stackoverflow.com/questions/208016/how-to-list-the-properties-of-a-javascript-object/3937321#3937321

Object.keys = Object.keys || (function () {
    var hasOwnProperty = Object.prototype.hasOwnProperty,
        hasDontEnumBug = !{toString:null}.propertyIsEnumerable("toString"),
        DontEnums = [
            'toString', 'toLocaleString', 'valueOf', 'hasOwnProperty',
            'isPrototypeOf', 'propertyIsEnumerable', 'constructor'
        ],
        DontEnumsLength = DontEnums.length;

    return function (o) {
        if (typeof o != "object" && typeof o != "function" || o === null)
            throw new TypeError("Object.keys called on a non-object");

        var result = [];
        for (var name in o) {
            if (hasOwnProperty.call(o, name))
                result.push(name);
        }

        if (hasDontEnumBug) {
            for (var i = 0; i < DontEnumsLength; i++) {
                if (hasOwnProperty.call(o, DontEnums[i]))
                    result.push(DontEnums[i]);
            }
        }

        return result;
    };
})();

//==================================================================================================
K3_InlineEditor = {
  updatePageFromObject: function(object_name, object_id, object) {
    $.each(object, function(attr_name, value) {
      var element = $('[data-object=' + object_name + '][data-object-id=' + object_id + '][data-attribute=' + attr_name + ']')
      if (value === null) value = '';
      if (element.length > 0) {
        if (element.html() != value) {
          //console.log("Updating", element, "to: " + value, "differs from old value: " + element.html());
          element.html(value)
        }
      }
    })
  },
}

  
//==================================================================================================
function initInlineEditor(options) {
  $('.editable').inlineEditor(options);
  $('.editable').inlineEditor({
    saving : function(event) {
      $('#last_saved_status').html('Saving...');
    },

    saveSuccess : function(event, data, msg, xhr) {
      // Once they submit their correction, remove the error message from the page.
      var element_data = $(this).data();
      var object_and_attr_identifier = {
        object:      element_data.object,
        'object-id': element_data['object-id'],
        attribute:   element_data.attribute,
      }
      object_and_attr_selector = '[data-object=' + element_data.object + '][data-object-id=' + element_data['object-id'] + '][data-attribute=' + element_data.attribute + ']'
      $('.alert' + object_and_attr_selector).remove();

      if (data['error']) {
        // There were no HTTP errors, but there was an application-layer error, so show it to the user
        var $alert = $('<p class="alert">' + data['error'] + '</p>').prependTo('#content');
        // Identify it so we can remove this error notice later if they submit again
        $.each(object_and_attr_identifier, function(key, value) {
          $alert.attr('data-' + key, value);
        })
        // Focus the editable element again so they can correct their mistake (in case they just tabbed out of it)
        $('.editable' + object_and_attr_selector + ':visible').eq(0).focus();
        $('#last_saved_status').html('<span style="color: #8A1F11">Not saved</span>');

      } else {
        var editor = InlineEditor.getEditor(this);
        var $this = $(this);
        editor.getObject(function(object) {
          var object_name = Object.keys(object)[0]
          //console.log(object_name, object[object_name])
          if (window[object_name] && window[object_name].updatePage) {
            // Special handler for this object class
            method = window[object_name].updatePage;
          } else {
            // Default handler
            method = K3_InlineEditor.updatePageFromObject;
          }
          method(object_name, $this.data('object-id'), object[object_name])
        })

        $('#last_saved_status').html('Saved seconds ago');
      }
    },
  });

  $ribbon = $('#k3_ribbon .row_2')
  if ($ribbon.length == 0)
    $ribbon = $('#k3_ribbon')
  $div = $('<div class="k3_inline_editor k3_section k3_inline_editor_icons"><ul></ul></div>').
    appendTo($ribbon)
  $ul = $div.find('ul')
  
  // show initial toolbar button layout, according to table at top
  $(toolbar_options).each(function (index) {
    var $elem = $('<li><a href="javascript:;" title="' + this.label + '">' + 
      '&nbsp;' +
      '</a></li>');
    $elem.addClass('button');
    $elem.addClass(this.klass);
    $ul.append($elem);
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
        if (typeof self.editor_cmd == 'function') {
          self.editor_cmd();
        } else {
          var arg = typeof self.cmd_args[1] == 'function' ? self.cmd_args[1]() : self.cmd_args[1];
          editor[self.editor_cmd](self.cmd_args[0], arg);
        }
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
    var btn = $('#k3_ribbon .' + this.klass);
    if (! editable_active) {
      btn.addClass('disabled');
    } else {
      var ined = InlineEditor.focusedEditor();
      if (! ined.isInline() || this.is_inline) {
        if (this.query_state_cmd) {
          ined[this.query_state_cmd](this.cmd_args[0], this.cmd_args[1]) ? btn.addClass('toggled_on') : btn.removeClass('toggled_on');
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

function handleVideo() {
  // var url = prompt('Enter URL:');
  // if (url) InlineEditor.focusedEditor().execCommand('insertHTML', '<video controls="controls" preload="meta"><source src="' + url + '" /></video>');
  InlineEditor.focusedEditor().execCommand('insertHTML',
    '<video id="1234v" controls="controls" style="width: 720px; height: 400px; display: block;">' +
      '<source src="http://cdn.kaltura.org/apis/html5lib/kplayer-examples/media/bbb_trailer_iphone.m4v" type="video/h264" />' +
      '<source src="http://cdn.kaltura.org/apis/html5lib/kplayer-examples/media/bbb400p.ogv" type="video/ogg" />' +
    '</video>'
  )
}
