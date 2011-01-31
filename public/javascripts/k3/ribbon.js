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
K3 = {
}

//--------------------------------------------------------------------------------------------------
// Data structures


K3_Ribbon = Class.extend({
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
  getTabs: function(tabs){
    this.tabs; // += tabs
  }
});

// A Tab represents both a tab and the pane underneath (containing Sections) that appears when you click on the tab
K3_Ribbon.Tab = Class.extend({
  init: function(name, label, sections) {
    this.name = name;
    this.label = label;
    this.sections = sections;
  },

  renderTab: function() {
    return $('<li><a href="#' + this.name + '">' + this.label + '</a></li>')
  },
  renderPane: function() {
    var pane = $('<div class="' + this.name + '"></div>')
    $.each(this.sections, function(index, section) {
      //console.log("section=", section);
      pane.append(section.render());
    })
    return pane;
  },
});

K3_Ribbon.Section = Class.extend({
  init: function(name, items) {
    this.name = name;
    this.items = items;
  },
  render: function() {
    var section = $('<div class="k3_section ' + this.name + '"></div>')
    $.each(this.items, function(index, item) {
      //console.log("append(item)=", item);
      section.append(item.options.element);
    });
    return section;
  },
});

K3_Ribbon.ToolbarItem = Class.extend({
  // element:
  // onClick
  // onDisable (inherits overridable default behavior?)
  init: function(options) {
    var self = this;
    this.options = options;
    this.element = options.element;
    $.each(options, function(key, value) {
      if (key.match(/^on/)) {
        var event_name = key.replace(/^on/, '').toLowerCase() + '.k3_ribbon';
        //console.log(event_name)
        self.element.bind(event_name, value);
      }
    });
  },
});

K3_Ribbon.Button = K3_Ribbon.ToolbarItem.extend({
  // onClick
  init: function(options) {
    this._super(options);
  },
});

K3_Ribbon.Drawer = Class.extend({
  init: function(options) {
    //...
  },
});

//--------------------------------------------------------------------------------------------------
// jQuery

(function($) {

  var methods = {
    init: function(options) {
      this.each(function() {
        $(this).addClass('k3_ribbon');
        var ribbon = $(this).data("k3_ribbon");
        if (ribbon) {
          ribbon.merge(options);
        } else {
          ribbon = new K3_Ribbon(options);
        }
        //console.log('ribbon=', ribbon)
        $(this).data("k3_ribbon", ribbon);
      });
    },

    render: function() {
      this.k3_ribbon('renderTabs');

      // We disable everything at init time
      // You have to explicitly call enable for any items that should be enabled.
      this.k3_ribbon('disableAll');
    },

    addTabs: function(tabs) {
      // TODO: look for duplicate tabs by name and merge their items

      var data = this.data('k3_ribbon');
      $.merge(data.tabs, tabs);
      this.data("k3_ribbon", data)
    },


    renderTabs: function(tabs_container, panes_container) {
      var tabs_container =   this.find('.tabs')
      var panes_container =  this.find('.panes')
      var data = this.data('k3_ribbon');

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
      var ribbon = this.data("k3_ribbon");
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

  $.fn.k3_ribbon = function(method) {
    /*
    if (!options) {
      var ribbon = $(this).data("k3_ribbon");
      return ribbon;
    }
    */
    
    // Method-calling logic
    if ( methods[method] ) {
      return methods[ method ].apply( this, Array.prototype.slice.call( arguments, 1 ));
    } else if ( typeof method === 'object' || ! method ) {
      return methods.init.apply( this, arguments );
    } else {
      $.error( 'Method ' +  method + ' does not exist on jQuery.k3_ribbon' );
    }

  }
    
})(jQuery);
