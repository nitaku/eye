// Generated by CoffeeScript 1.10.0
(function() {
  var View, setup_init,
    slice = [].slice;

  window.app = {};

  setup_init = function(c, init) {
    if (c.prototype.inits == null) {
      c.prototype.inits = [];
    }
    c.prototype.inits.push(init);
    return c.prototype.init = function(conf) {
      var i, len, m, ref, results;
      ref = this.inits;
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        m = ref[i];
        results.push(m.call(this, conf));
      }
      return results;
    };
  };

  window.observable = function(c) {
    setup_init(c, function(config) {
      this._dispatcher = d3.dispatch.apply(d3, config.events);
      return this._next_id = 0;
    });
    c.prototype.on = function(event_type_ns, callback) {
      var event_type, event_type_full, namespace, splitted_event_type_ns;
      splitted_event_type_ns = event_type_ns.split('.');
      event_type = splitted_event_type_ns[0];
      if (splitted_event_type_ns.length > 1) {
        namespace = splitted_event_type_ns[1];
      } else {
        namespace = this._next_id;
        this._next_id += 1;
      }
      event_type_full = event_type + '.' + namespace;
      this._dispatcher.on(event_type_full, callback);
      return event_type_full;
    };
    c.prototype.trigger = function() {
      var args, event_type;
      event_type = arguments[0], args = 2 <= arguments.length ? slice.call(arguments, 1) : [];
      this._dispatcher.apply(event_type, this, args);
      return this;
    };
    return c;
  };

  window.observer = function(c) {
    setup_init(c, function() {
      return this._bindings = [];
    });
    c.prototype.listen_to = function(observed, event, cb) {
      return this._bindings.push({
        observed: observed,
        event_type: observed.on(event, cb)
      });
    };
    c.prototype.stop_listening = function() {
      return this._bindings.forEach((function(_this) {
        return function(l) {
          return l.observed.on(l.event_type, null);
        };
      })(this));
    };
    return c;
  };

  window.View = View = (function() {
    function View(conf) {
      if (conf.tag == null) {
        conf.tag = 'div';
      }
      this.el = document.createElement(conf.tag);
      this.d3el = d3.select(this.el);
      this.d3el.classed(this.constructor.name, true);
      if (conf.parent != null) {
        this.append_to(conf.parent, conf.prepend);
      }
    }

    View.prototype.append_to = function(parent, prepend) {
      var p_el;
      if (parent.el != null) {
        p_el = parent.el;
      } else {
        if (parent.node != null) {
          p_el = parent.node();
        } else {
          p_el = d3.select(parent).node();
        }
      }
      if (prepend) {
        return p_el.insertBefore(this.el, p_el.firstChild);
      } else {
        return p_el.appendChild(this.el);
      }
    };

    View.prototype.compute_size = function() {
      this.width = this.el.getBoundingClientRect().width;
      return this.height = this.el.getBoundingClientRect().height;
    };

    return View;

  })();

}).call(this);
