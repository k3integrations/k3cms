/*
 * Simple JavaScript Inheritance
 * By John Resig http://ejohn.org/
 * MIT Licensed.
 * http://ejohn.org/blog/simple-javascript-inheritance/
 */
(function() {
  var initializing = false, fnTest = /xyz/.test(function() {xyz;}) ? /\b_super\b/ : /.*/;
  // The base Class implementation (does nothing)
  this.Class = function() {};
  
  // Create a new Class that inherits from this class
  Class.extend = function(prop) {
    var _super = this.prototype;
    
    // Instantiate a base class (but only create the instance,
    // don't run the init constructor)
    initializing = true;
    var prototype = new this();
    initializing = false;
    
    // Copy the properties over onto the new prototype
    for (var name in prop) {
      // Check if we're overwriting an existing function
      prototype[name] = typeof prop[name] == "function" &&
        typeof _super[name] == "function" && fnTest.test(prop[name]) ?
        (function(name, fn){
          return function() {
            var tmp = this._super;
            
            // Add a new ._super() method that is the same method
            // but on the super-class
            this._super = _super[name];
            
            // The method only need to be bound temporarily, so we
            // remove it when we're done executing
            var ret = fn.apply(this, arguments);
            this._super = tmp;
            
            return ret;
          };
        })(name, prop[name]) :
        prop[name];
    }
    
    // The dummy class constructor
    function Class() {
      // All construction is actually done in the init method
      if ( !initializing && this.init )
        this.init.apply(this, arguments);
    }
    
    // Populate our constructed prototype object
    Class.prototype = prototype;
    
    // Enforce the constructor to be what we expect
    Class.constructor = Class;

    // And make this class extendable
    Class.extend = arguments.callee;
    
    return Class;
  };
})();


//--------------------------------------------------------------------------------------------------
// Miscellaneous helper methods

function assertValidKeys(options, valid_keys) {
  $.each(options, function(key, value) {
    var recognized = false;
    // TODO: replace with detect()
    $.each(valid_keys, function(i, valid_key) {
      recognized = recognized || key.match(valid_key);
    });

    //if ($.inArray(key, valid_keys) === -1) {
    if (!recognized) {
      $.error("'" + key + "' is not a recognized option");
    }
  })
}

// https://developer.mozilla.org/en/JavaScript/Reference/Global_Objects/Date
function ISODateString(d) {
  function pad(n){return n<10 ? '0'+n : n}
  return d.getUTCFullYear()+'-'
    + pad(d.getUTCMonth()+1)+'-'
    + pad(d.getUTCDate())+'T'
    + pad(d.getUTCHours())+':'
    + pad(d.getUTCMinutes())+':'
    + pad(d.getUTCSeconds())+'Z'
}

//--------------------------------------------------------------------------------------------------
K3cms = {
}

//--------------------------------------------------------------------------------------------------
// Data structures

// A Ribbon has multiple Tabs
// A Tab has multiple Sections
// A section has many Buttons
//
// To retrieve a ribbon, get it from the element itself, like this: $('#k3cms_ribbon').k3cms_ribbon('get')
// To retrieve a specific tab, get it through the ribbon API:       $('#k3cms_ribbon').k3cms_ribbon('get').tabsByName().editing_tab
// This API could probably be improved. (I like the jQuery Tools API best of all I've seen, and hope to use that as the basis when I rework the API...)
//
K3cms_Ribbon = Class.extend({
  init: function(options) {
    this.tabs = [];
    this.always_enabled = [];
    this.merge(options);
  },
  merge: function(options) {
    if (typeof options === "object") {
      // We can't just do $.extend(this, options); because old tabs array would get overwritten with new tabs array :(
      //console.log("options=", options);
      var tabs =           options.tabs           || []; delete options.tabs;
      var always_enabled = options.always_enabled || []; delete options.always_enabled;
      $.merge(this.tabs, tabs);
      $.merge(this.always_enabled, always_enabled);
      $.extend(this, options);
    }
  },

  refresh: function() {
    $.each(this.tabs, function(index, tab) {
      tab.refresh();
    })
  },

  tabsByName: function() {
    var tabs = {};
    $.each(this.tabs, function(index, tab) {
      tabs[tab.name] = tab;
    })
    return tabs;
  },
});

$.extend(K3cms_Ribbon, {
  edit_mode_on: function() {
    return !!document.cookie.match(/edit_mode=true/)
  },

  bindEventHandlers: function(element, options) {
    $.each(options, function(key, value) {
      if (key.match(/^on/)) {
        delete options[key];
        var event_name = key.replace(/^on/, '').toLowerCase() + '.k3cms_ribbon';
        //console.log(event_name)
        element.bind(event_name, value);
      }
    });
  },

  set_saved_status: function(last_saved_at) {
    if (last_saved_at instanceof Date) {
      var status_element = $('li.last_saved_status');
      //console.log("last_saved_at=", last_saved_at);
      status_element.html('');
      status_element.
        append("Saved ").
        append($('<span/>', { 'class': "timeago",
          title: ISODateString(last_saved_at), 
          html: last_saved_at
        })).
        append($('<button/>', { 'class': "save_button",
          click: function() { K3cms_Ribbon.onSaving(); }
        }));
      status_element.find('.timeago').timeago();
      K3cms_Ribbon.set_dirty_status(false);
    } else if (last_saved_at == 'Error') {
      // TODO: update this status to indicate that there was an error
    } else {
      console.debug('Expected a Date object but got', last_saved_at);
    }
  },

  set_dirty_status: function(dirty) {
    if (dirty) {
      $('#k3cms_ribbon .save_button').html('Save now').removeAttr('disabled');
    } else {
      $('#k3cms_ribbon .save_button').html('Saved').attr('disabled', true);
    };
  },
  onSaving: function(dirty) {
    $('#k3cms_ribbon .save_button').html('Saving...').attr('disabled', true);
  },

})

// A Tab represents both a tab and the pane underneath (containing Sections) that appears when you click on the tab
K3cms_Ribbon.Tab = Class.extend({
  init: function(name, options) {
    assertValidKeys(options, ['label', 'sections', /^on/]);
    this.name = name;
    $.extend(this, options);
  },

  renderTab: function() {
    var element = $('<li><a href="#' + this.name + '">' + this.label + '</a></li>')
    K3cms_Ribbon.bindEventHandlers.call(this, element, this);
    return element;
  },
  renderPane: function() {
    var pane = $('<div class="' + this.name + '"></div>')
    $.each(this.sections, function(index, section) {
      //console.log("section=", section);
      pane.append(section.render());
    })
    return pane;
  },

  refresh: function() {
    $.each(this.sections, function(index, section) {
      section.refresh();
    })
  },

  sectionsByName: function() {
    var sections = {};
    $.each(this.sections, function(index, section) {
      sections[section.name] = section;
    })
    return sections;
  },
});

K3cms_Ribbon.Section = Class.extend({
  init: function(name, options) {
    this.name = name;
    assertValidKeys(options, ['label', 'items', /^on/]);
    $.extend(this, options);
  },
  render: function() {
    var section = $('<div class="k3cms_section ' + this.name + '"></div>')
    $.each(this.items, function(index, item) {
      //console.log("append(item)=", item);
      section.append(item.element);
    });
    return section;
  },

  refresh: function() {
    $.each(this.items, function(index, item) {
      item.refresh();
    })
  },
});

K3cms_Ribbon.ToolbarItem = Class.extend({
  // element:
  // onClick
  // onDisable (inherits overridable default behavior?)
  init: function(options) {
    $.extend(this, options);
    var self = this;
    K3cms_Ribbon.bindEventHandlers.call(this, this.element, options);
  },

  refresh: $.noop,
});

K3cms_Ribbon.Button = K3cms_Ribbon.ToolbarItem.extend({
  // onClick
  init: function(options) {
    this._super(options);
  },
});

K3cms_Ribbon.Drawer = Class.extend({
  init: function(id, options) {
    this.id = id;
    $.extend(this, options);
  },
  render: function() {
    var self = this;
    var root = $('<div/>', { id: this.id, 'class': 'drawer hidden ' + this.id });
    root.append('<h2 id="' + this.id + '_title">' + entityEscape(this.title) + '</h2>');
    var form;
    root.append(form = $('<form id="' + this.id + '_form" class="form ' + this.id + '" accept-charset="UTF-8">'));
      form.append(this.fields);
      form.append('<input type="submit" id="' + this.id + '_submit" value="' + (this.submit_text || 'Submit') + '">&nbsp; ');
      form.append('<a onclick="toggleDrawer(\'' + this.id + '\'); return false;" href="#">Cancel</a>');

    //K3cms_Ribbon.bindEventHandlers.call(this, root, this);

    // Set id attr based on name
    root.find('input').each(function() {
      if (!$(this).attr('id')) {
        $(this).attr('id', self.id + '_' + $(this).attr('name'));
      };
      // If not already prefixed (as is the case for K3cms_Ribbon.Drawer.FloatField, where we use generic ids like 'float_none'), we need to prefix now...
      if ($(this).attr('id') && $(this).attr('id').indexOf(self.id + '_') !== 0) {
        $(this).attr('id', self.id + '_' + $(this).attr('id'));
      };
    });
    root.find('label').each(function() {
      if (!$(this).attr('for')) {
        //$(this).attr('for', self.id + '_' + $(this).data('name'));
        $(this).attr('for', $(this).data('name'));
      };
      // If not already prefixed (as is the case for K3cms_Ribbon.Drawer.FloatField, where we use generic ids like 'float_none'), we need to prefix now...
      if ($(this).attr('for') && $(this).attr('for').indexOf(self.id + '_') !== 0) {
        $(this).attr('for', self.id + '_' + $(this).attr('for'));
      };
    });

    root.data('drawer', this);
    return root;
  },

  // If get_editable returns an object, we are editing an *existing* editable -- use populate_from_editable
  // If get_editable returns null, we are inserting *new* content -- use populate_with_defaults
  get_editable: function() {
  },
  default_populate_with_defaults: function() {
    this.find('input:text').val('');
  },
  populate_with_defaults: function() {
    this.default_populate_with_defaults();
  },
  get: function() {
    //return $('#k3cms_drawers .' + this.id + '.drawer');
    return $('#k3cms_drawers #' + this.id);
  },
  find: function(selector) {
    return this.get().find(selector);
  },
  editable_container: function() {
    return this.get().data('focused');
  },

});

//--------------------------------------------------------------------------------------------------
// jQuery

(function($) {

  var methods = {
    init: function(options) {
      this.addClass('k3cms_ribbon');
      var ribbon = this.data("k3cms_ribbon");
      if (ribbon) {
        ribbon.merge(options);
      } else {
        ribbon = new K3cms_Ribbon(options);
      }
      //console.log('ribbon=', ribbon)
      this.data("k3cms_ribbon", ribbon);
      return ribbon;
    },

    get: function() {
      var ribbon = this.data('k3cms_ribbon');
      return ribbon;
    },

    render: function() {
      this.k3cms_ribbon('renderTabs');

      // We disable everything at init time
      // You have to explicitly call enable for any items that should be enabled.
      this.k3cms_ribbon('disableAll');

      $("ul.tabs").tabs("div.panes > div");
    },

    refresh: function() {
      var ribbon = this.data('k3cms_ribbon');
      ribbon.refresh();
    },

    addTabs: function(tabs) {
      // TODO: look for duplicate tabs by name and merge their items

      var ribbon = this.data('k3cms_ribbon');
      $.merge(ribbon.tabs, tabs);
      this.data("k3cms_ribbon", ribbon)
    },


    renderTabs: function(tabs_container, panes_container) {
      var tabs_container =   this.find('.tabs')
      var panes_container =  this.find('.panes')
      var data = this.data('k3cms_ribbon');

      $.each(data.tabs, function(index, tab) {
        tabs_container.append(tab.renderTab());
        panes_container.append(tab.renderPane());
      })
    },

    isEnabled: function() {
      // TODO: check ancestors too (whole section may be disabled)
      return !this.hasClass('disabled');
    },

    enable: function(selector) {
      // tab, section, item

      var el = selector ? this.find(selector) : this;
      //console.log(selector, el);
      el.removeClass('disabled')
    },

    disableAll: function() {
      var ribbon = this.data("k3cms_ribbon");
      this.find('.button').each(function() {
        var item = $(this);
        //console.log("item=", item);
        item.addClass('disabled');
      });
      $.each(ribbon.always_enabled, function(index, selector) {
        if ($(selector).length == 0) console.log(selector + " not found");
        $(selector).removeClass('disabled');
      });
      
      
    },

  };

  $.fn.k3cms_ribbon = function(method) {
    /*
    if (!options) {
      var ribbon = $(this).data("k3cms_ribbon");
      return ribbon;
    }
    */
    
    // Method-calling logic
    if ( methods[method] ) {
      return methods[ method ].apply( this, Array.prototype.slice.call( arguments, 1 ));
    } else if ( typeof method === 'object' || ! method ) {
      return methods.init.apply( this, arguments );
    } else {
      $.error( 'Method ' +  method + ' does not exist on jQuery.k3cms_ribbon' );
    }

  }
    
})(jQuery);
