
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
  ['Insert/edit link', 'link',           true,  function(){toggleDrawer('link_drawer')},  false, false],
  ['Remove link',      'unlink',         true,  'execCommand', 'queryCommandState', 'queryCommandEnabled', ['unlink']],
  ['Insert/edit Image', 'image',         false, function(){toggleDrawer('image_drawer')}, false, false],
  ['Insert/edit Video', 'video',         false, function(){toggleDrawer('video_drawer')}, false, InlineEditor.isFocusedEditor],
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
  ['Paragraph',        'blockP',         false, 'switchToBlock', 'isCurrentBlock',   false,                ['p']],
  //['Preformatted',   'blockPre',       false, 'switchToBlock', 'isCurrentBlock',   false,                ['pre']],
  //['Address',        'blockAddress',   false, 'switchToBlock', 'isCurrentBlock',   false,                ['address']],
  ['Heading 1',        'blockH1',        false, 'switchToBlock', 'isCurrentBlock',   false,                ['h1']],
  ['Heading 2',        'blockH2',        false, 'switchToBlock', 'isCurrentBlock',   false,                ['h2']],
  ['Heading 3',        'blockH3',        false, 'switchToBlock', 'isCurrentBlock',   false,                ['h3']],
  ['Heading 4',        'blockH4',        false, 'switchToBlock', 'isCurrentBlock',   false,                ['h4']],
  ['Heading 5',        'blockH5',        false, 'switchToBlock', 'isCurrentBlock',   false,                ['h5']],
  ['Heading 6',        'blockH6',        false, 'switchToBlock', 'isCurrentBlock',   false,                ['h6']],
  ['Plain',            'blockDiv',       false, 'switchToBlock', 'isCurrentBlock',   false,                ['div']],
];

var drawer_defaults = {
  new_title_prefix: 'New ',
  edit_title_prefix: 'Edit ',
  new_submit: 'Insert',
  edit_submit: 'Update'
};
var drawer_options = {
  link_drawer: {
    title: 'Link',
    fields: [
      {'id': 'url', label: 'URL'}
    ],
    get_editable: function() {
      // TODO: push this into core as InlineEditor.Selection.getFirstIntersecting('a') or some such?
      var editor = InlineEditor.focusedEditor();
      if (! editor) return null;
      var rng = InlineEditor.Range.getCurrent();
      var anchors = $(editor.node).find('a').filter(function () {
        return InlineEditor.Selection.intersectsNode(this);
      });
      // If we found an a element, return it
      if (anchors.length > 0) {
        return anchors.get(0);
      }
      // Otherwise, consider using the selected text, if it looks like it could be a URL
      if (rng.range.startContainer.nodeName == '#text') {
        var val = rng.range.startContainer.nodeValue;
        if ( val.match(/^[\S]*$/) ) {
          return val;
        }
      }
      return null;
    },
    populate_editable_fields: function(editable) {
      if (typeof editable == 'string') {
        $('#link_drawer_url').val(editable);
      } else { // if (editable.nodeName == 'A') {
        $('#link_drawer_url').val(editable.href);
      }
    },
    value_to_update_editable_with: function() {
      var val = $('#link_drawer_url').val();
      if (val.match(/^[\w-]+:\/\/?/)) {
        return val;
      } else {
        // If it doesn't already have a protocol, add a default. Otherwise, if they go to edit it again, when it reads a.href, it will have the entire base URL of the site prepended (not just a protocol), which means the domain name might appear twice.
        return 'http://' + val;
      }
    },
    onCreate: function() {
      InlineEditor.focusedEditor().execCommand('createLink', this.value_to_update_editable_with());
    },
    onUpdate: function(a_node) {
      a_node.href = this.value_to_update_editable_with();
    }
  },

  image_drawer: {
    title: 'Image',
    fields: [
      {'id': 'url',      label: 'URL'}//,
      // {'id': 'position', label: 'Positioning', type: 'select', options: [
      //   {'id': 'inline',   label: 'Inline'},
      //   {'id': 'left',     label: 'Float Left'},
      //   {'id': 'right',    label: 'Float Right'}
      // ]}
    ],
    get_editable: function() {
      // TODO: push this into core as InlineEditor.Selection.getOnlyContained('img') or some such?
      var editor = InlineEditor.focusedEditor();
      if (! editor) return null;
      var rng = InlineEditor.Range.getCurrent();
      var images = $(editor.node).find('img').filter(function () {
        return rng.approxEquals(new InlineEditor.Range(this));
      });
      return images.length > 0 ? images.get(0) : null;
    },
    populate_editable_fields: function(img_node) {
      $('#image_drawer_url').val(img_node.src);
      // $('#image_drawer_position').val(img_node.style.float); // TODO float/inline positioning
    },
    onCreate: function() {
      // for testing try @86x62:
      // http://localhost:3000/images/logo.png
      var editor = InlineEditor.focusedEditor().execCommand('insertImage', $('#image_drawer_url').val());
    },
    onUpdate: function(img_node) {
      img_node.src = $('#image_drawer_url').val();
      // TODO: float/inline positioning
    }
  },
  video_drawer: {
    title: 'Video',
    fields: [
      // see: http://diveintohtml5.org/video.html#what-works
      {'id': 'h264_url', label: 'MP4 H.264/AAC Format URL', size: 60},
      {'id': 'ogg_url',  label: 'Ogg Theora/Vorbis Format URL', size: 60},
      {'id': 'width',    label: 'Width',  size: 10},
      {'id': 'height',   label: 'Height', size: 10}
    ],
    get_editable: function() {
      return (InlineEditor.isFocusedEditor() && window.document.activeElement.nodeName == 'VIDEO') ? window.document.activeElement : null;
    },
    populate_editable_fields: function(video_node) {
      var h264_tags = $(video_node).find('source[type="video/h264"]');
      var ogg_tags = $(video_node).find('source[type="video/ogg"]');
      $('#video_drawer_h264_url').val(h264_tags.length > 0 ? h264_tags.get(0).src : '');
      $('#video_drawer_ogg_url').val(ogg_tags.length > 0 ? ogg_tags.get(0).src : '');
      $('#video_drawer_width').val(video_node.width);
      $('#video_drawer_height').val(video_node.height);
    },
    onCreate: function() {
      // for testing try @720x400:
      // http://cdn.kaltura.org/apis/html5lib/kplayer-examples/media/bbb_trailer_iphone.m4v
      // http://cdn.kaltura.org/apis/html5lib/kplayer-examples/media/bbb400p.ogv
      var width    = $('#video_drawer_width').val()    == '' ? '' : ' width="'  + $('#video_drawer_width').val()  + '"';
      var height   = $('#video_drawer_height').val()   == '' ? '' : ' height="' + $('#video_drawer_height').val() + '"';
      var h264_tag = $('#video_drawer_h264_url').val() == '' ? '' : '<source src="' + $('#video_drawer_h264_url').val() + '" type="video/h264" />';
      var ogg_tag  = $('#video_drawer_ogg_url').val()  == '' ? '' : '<source src="' + $('#video_drawer_ogg_url').val()  + '" type="video/ogg" />';
      InlineEditor.focusedEditor().execCommand('insertHTML', '<video controls="controls" style="display: block;"' + width + height + '>' + h264_tag + ogg_tag + '</video>');
    },
    onUpdate: function(video_node) {
      var h264_tags = $(video_node).find('source[type="video/h264"]');
      var ogg_tags = $(video_node).find('source[type="video/ogg"]');
      if (h264_tags.length > 0 && $('#video_drawer_h264_url').val() != '') {
        h264_tags.get(0).src = $('#video_drawer_h264_url').val();
      } else if (h264_tags.length > 0) {
        h264_tags.remove();
      } else {
        $(video_node).append('<source src="' + $('#video_drawer_h264_url').val() + '" type="video/h264" />');
      }
      if (ogg_tags.length > 0 && $('#video_drawer_ogg_url').val() != '') {
        ogg_tags.get(0).src = $('#video_drawer_ogg_url').val();
      } else if (ogg_tags.length > 0) {
        ogg_tags.remove();
      } else {
        $(video_node).append('<source src="' + $('#video_drawer_ogg_url').val() + '" type="video/ogg" />');
      }
      video_node.width = $('#video_drawer_width').val();
      video_node.height = $('#video_drawer_height').val();
    }
  }
};

var structured_toolbar_options = [];
$(toolbar_options).each(function (i) {
  option = {
    label:             this[0],
    'class':           this[1],
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
  updatePageFromObject: function(object_name, object_id, object, source_element) {
    $.each(object, function(attr_name, value) {
      if (value === null) value = '';
      $('[data-object=' + object_name + '][data-object-id=' + object_id + '][data-attribute=' + attr_name + ']').each(function (index) {
        var element = $(this);
        if (element.get(0) == source_element.get(0)) {
          // Don't update the element they just saved with the data loaded from the database because they may have continued editing immediately after saving and we don't want to blow those changes away
          //console.log('Skipping', element)
        } else {
          if (element.html() != value) {
            //console.log("Updating", element, "to: " + value, "differs from old value: " + element.html());
            element.html(value)
          } else {
            //console.log("Not updating", element, "to: '" + value, "'; doesn't differ from old value: '" + element.html() + "'");
          }
        }
      })
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
          method(object_name, element_data['object-id'], object[object_name], this)
        })

        $('#last_saved_status').html('Saved seconds ago');
      }
    },
  });

  //------------------------------------------------------------------------------------------------
  // Integrate with K3_Ribbon

  var tab = new K3_Ribbon.Tab('k3_inline_editor', {
    label: 'Edit', 
    sections: [
      new K3_Ribbon.Section('inline_styles', {label: 'Inline styles', items: []}),
      new K3_Ribbon.Section('insert',        {label: 'Insert', items: []}),
      new K3_Ribbon.Section('block_styles',  {label: 'Paragraph/block styles', items: []}),
    ],
    onClick: function() {
      InlineEditor.last_focused_element && InlineEditor.last_focused_element.focus();
      InlineEditor.last_selection       && InlineEditor.last_selection.restore();
    },
  })

  //------------------------------------------------------------------------------------------------
  // Add all the buttons to the ribbon/toolbar, according to the configuration stored in toolbar_options
  $(toolbar_options).each(function (index) {
    var toolbar_option = this;
    if (!this['class'].match(/^block/)) {
      var button = new K3_Ribbon.Button({
        element: $('<li/>', { 'class': "icon button " + this['class'] }).
          append($('<a/>', {title: this.label, href: "javascript:;", html: '&nbsp;'})),
        onMousedown: function() {
          $(this).k3_ribbon('isEnabled') && $(this).trigger('invoke');

          // returning false doesn't cancel losing editor focus in IE, here's a nasty hacky fix!
          if (navigator.userAgent.match(/MSIE/)) {
            $(editor.node).one('blur', function () {
              this.focus();
            });
          }

          return false;
        },
        onInvoke: function() {
          var editor = InlineEditor.focusedEditor();
          // ignore button presses if no editable area is selected (you can also use InlineEditor.isFocusedEditor())
          if (! editor || ! editor.isEnabled() || $(this).hasClass('disabled')) {
            return false;
          }

          // execute the command
          if (typeof toolbar_option.editor_cmd == 'function') {
            toolbar_option.editor_cmd();
          } else {
            var arg = typeof toolbar_option.cmd_args[1] == 'function' ? toolbar_option.cmd_args[1]() : toolbar_option.cmd_args[1];
            editor[toolbar_option.editor_cmd](toolbar_option.cmd_args[0], arg);
          }
        },
        refresh: function() {
          var editor = InlineEditor.focusedEditor();
          var btn = this.element;
          btn.removeClass('toggled_on');
          if (! editor) {
            btn.addClass('disabled');
          } else {
            // Block level editor buttons are disabled for inline-level editable fields.
            // If we're editing a block element, then show all buttons
            // If we're editing an inline element, then only show is_inline buttons
            if (! editor.isInline() || toolbar_option.is_inline) {
              if (toolbar_option.query_state_cmd) {
                if (editor[toolbar_option.query_state_cmd](toolbar_option.cmd_args[0], toolbar_option.cmd_args[1])) {
                  //console.log(toolbar_option.class, 'is toggled on');
                  btn.addClass('toggled_on')
                }
              }
              if (toolbar_option.query_enabled_cmd) {
                if (
                  typeof toolbar_option.query_enabled_cmd == 'function' ?
                  toolbar_option.query_enabled_cmd() :
                  editor[toolbar_option.query_enabled_cmd](toolbar_option.cmd_args[0], toolbar_option.cmd_args[1])
                ) {
                  btn.removeClass('disabled')
                } else {
                  btn.addClass('disabled');
                }
              } else {
                btn.removeClass('disabled');
              }
            } else {
              btn.addClass('disabled');
            }
          }
        }
      })

      tab.sectionsByName().inline_styles.items.push(button);
    }
  });

  //------------------------------------------------------------------------------------------------
  // Add list of block styles as a drop-down select menu
  var select_item = new K3_Ribbon.ToolbarItem({
    element: $('<li/>', {}).
      append($('<select/>', {'class': 'select_block_style'})),
    refresh: function() {
      var editor = InlineEditor.focusedEditor();
      var select = this.element.find('select');
      select.get(0).selectedIndex = -1;
      //console.log("select=", select);
      if (! editor) {
        select.attr('disabled', true);
      } else {
        select.removeAttr('disabled');
        var current_block_style = null;

        $(toolbar_options).each(function (index) {
          var option = $('#k3_ribbon .' + this['class']);
          if (this['class'].match(/^block/) && 
            (! editor.isInline() || this.is_inline)
          ) {
            if (this.query_state_cmd) {
              if (editor[this.query_state_cmd](this.cmd_args[0], this.cmd_args[1])) {
                //console.log(this.class, 'is toggled on');
                current_block_style = this['class'];
                option.addClass('toggled_on')
              } else {
                option.removeClass('toggled_on');
              }
            }

            if (this.query_enabled_cmd) {
              if (
                typeof this.query_enabled_cmd == 'function' ?
                this.query_enabled_cmd() :
                editor[this.query_enabled_cmd](this.cmd_args[0], this.cmd_args[1])
              ) {
              // if (editor[this.query_enabled_cmd](this.cmd_args[0], this.cmd_args[1])) {
                option.removeAttr('disabled');
              } else {
                option.attr('disabled', true);
              }
            } else {
              option.removeAttr('disabled');
            }
          } else {
            option.attr('disabled', true);
          }

        });
        select.val(current_block_style);
      }
    },
  })

  var select = select_item.element.find('select');
  $(toolbar_options).each(function (index) {
    var toolbar_option = this;

    if (this['class'].match(/^block/)) {
      var option = $('<option>' + this.label + '</option>');
      option.attr('class', this['class']);
      option.attr('value', this['class']);
      //option.innerHTML = this.label;
      select.append(option);

      option.bind('invoke', function() {
        var editor = InlineEditor.focusedEditor();
        // ignore button presses if no editable area is selected (you can also use InlineEditor.isFocusedEditor())
        if (! editor || ! editor.isEnabled() || $(this).hasClass('disabled')) {
          return false;
        }

        // execute the command
        if (typeof toolbar_option.editor_cmd == 'function') {
          toolbar_option.editor_cmd();
        } else {
          var arg = typeof toolbar_option.cmd_args[1] == 'function' ? toolbar_option.cmd_args[1]() : toolbar_option.cmd_args[1];
          editor[toolbar_option.editor_cmd](toolbar_option.cmd_args[0], arg);
        }
      });
    }
  });

  // Translate the 'change' event on the select into an 'invoke' event for the relevant *option*
  select.change(function (event) {
    //console.log($(this).get(0).selectedIndex)
    var option = $(this).find("option:selected").eq(0)

    // When the user clicks on the select element in the toolbar, it causes the editable element to lose focus, so we need to restore focus to the editable.
    // (When the user clicks on a normal button, this isn't a problem, because we bound 'mousedown' instead of 'click'.)
    InlineEditor.last_focused_element && InlineEditor.last_focused_element.focus();
    //InlineEditor.last_selection       && InlineEditor.last_selection.restore();

    option.trigger('invoke')
  })
  tab.sectionsByName().block_styles.items.push(select_item);

  //------------------------------------------------------------------------------------------------


  /*
  $toolbar.mousedown(function (event) {
    InlineEditor.clicking_in_toolbar = true;
    //console.log("mousedown: InlineEditor.clicking_in_toolbar=", InlineEditor.clicking_in_toolbar);
  });
  $toolbar.bind('focusout mouseup', function (event) {
    InlineEditor.clicking_in_toolbar = false;
    //console.log(event.type + ": InlineEditor.clicking_in_toolbar=", InlineEditor.clicking_in_toolbar);
  });
  */

  $('#k3_ribbon').k3_ribbon({tabs: [tab]})

  //------------------------------------------------------------------------------------------------

  // set initial toolbar button state, and set handlers to keep up to date
  refreshButtons();
  $('.editable').bind('cursor_move custom_focus', function (event) {
    refreshButtons();
  });
  // $('.editable').find(InlineEditor.SUB_FOCUSABLE_SELECTOR).bind('custom_focus', function (event) {
  //   refreshButtons();
  // });
  
  // draw javascript-only drawers
  var dwr_def = drawer_defaults;
  for (var dwr_id in drawer_options) {
    var dwr = drawer_options[dwr_id];
    $('#k3_drawers').append(drawerContents(dwr_id, '', dwr.fields));

    $('.' + dwr_id + '.drawer').bind('open', {dwr_id: dwr_id, dwr: dwr}, function(event) {
      // When the drawer is opened, cretae the form and populate it from the editable, if possible.
      var editable = event.data.dwr.get_editable();
      if (editable == null) {
        $('#' + event.data.dwr_id + '_title').text(dwr_def.new_title_prefix + event.data.dwr.title);
        $('#' + event.data.dwr_id + '_submit').val(dwr_def.new_submit);
        $(event.data.dwr.fields).each(function(idx, field) {
          $('#' + event.data.dwr_id + '_' + field.id).val('');
        });
      } else {
        $('#' + event.data.dwr_id + '_title').text(dwr_def.edit_title_prefix + event.data.dwr.title);
        $('#' + event.data.dwr_id + '_submit').val(dwr_def.edit_submit);
        event.data.dwr.populate_editable_fields(editable);
      }
    });

    $('#' + dwr_id + '_form').bind('submit', {dwr_id: dwr_id, dwr: dwr}, function(event) {
      toggleDrawer(event.data.dwr_id);
      var editable = event.data.dwr.get_editable();
      if (editable && editable.nodeName == 'A') {
        event.data.dwr.onUpdate(editable);
      } else {
        event.data.dwr.onCreate();
      }
      return false;
    });
  }
  
  // $('.editable video').focus(function(event) {
  //   // console.debug(event);
  //   $(event.currentTarget).addClass('selected');
  // });
  // $('.editable video').blur(function(event) {
  //   // console.debug(event);
  //   $(event.currentTarget).removeClass('selected');
  // });
}


// refreshing toolbar button classes to show toggled/disabled states, depending on where the cursor currently is
function refreshButtons() {
  // refreshButtons gets triggered by checkCursorMove by checkMoveOrChangeHandler by the blur event when you click the select.
  // By that point, the select has the focus and not the editable, so if we let this function run as normal, it would disable everything in the toolbar.
  // So as a workaround, we set clicking_in_toolbar to true whenever the focus is in the toolbar but will be returned to the editable shortly so we don't want the toolbar being updated while the user interacts with tho toolbar.
  if (InlineEditor.clicking_in_toolbar) {
    //console.log("InlineEditor.clicking_in_toolbar=", InlineEditor.clicking_in_toolbar);
    return;
  }

  var ribbon = $('#k3_ribbon').k3_ribbon('get');
  ribbon.refresh();
}

function toggleDrawer(id) {
  var drawer = $('.' + id + '.drawer');
  var opening = !drawer.is(':visible');
  if (opening) {
    // Opening drawer
    drawer.data('focused', this.document.activeElement);
    drawer.data('selected', new InlineEditor.Selection(this.document));
    // console.debug('focus:', drawer.data('focused').node)
    // console.debug('selected:', drawer.data('selected').anchorNode, ',', drawer.data('selected').anchorOffset, '-', drawer.data('selected').focusNode, ',', drawer.data('selected').focusOffset);
    drawer.trigger('open');
  } else {
    // Closing drawer
    if (drawer.data('focused'))  drawer.data('focused').focus();
    if (drawer.data('selected')) drawer.data('selected').restore();
    drawer.trigger('close');
  }
  drawer.slideToggle();
  if (opening) {
    drawer.find(':input:visible:eq(0)').focus()
  }

}

function drawerContents(id, title, fieldsinfo, submittext) {
  var fields = '';
  for (var idx in fieldsinfo) {
    fields += '<div class="field">' +
      fieldsinfo[idx].label + ':' +
      '<input type="text" size="' + (fieldsinfo[idx].size || 30) + '" id="' + id + '_' + fieldsinfo[idx].id + '" name="' + id + '[' + fieldsinfo[idx].id + ']">' +
    '</div>'
  }
  return '<div class="drawer hidden ' + id + '">' +
    '<h2 id="' + id + '_title">' + entityEscape(title) + '</h2>' +
    '<form id="' + id + '_form" class="form ' + id + '" accept-charset="UTF-8">' +
      fields +
      '<input type="submit" id="' + id + '_submit" value="' + (submittext || 'Submit') + '">&nbsp; ' +
      '<a onclick="toggleDrawer(\'' + id + '\'); return false;" href="#">Cancel</a>' +
    '</form>' +
  '</div>';
}
function entityEscape(text) {
  return $('<div/>').text(text).html();
}
