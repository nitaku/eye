# make a function (or class) global
# window.global = (f) ->
#   window[f.name] = f
  
#   return f

# set up an array of initializer methods
# each one of these methods will be called
# by invoking @init(), usually within the user
# class constructor
setup_init = (c, init) ->
  if not c::inits?
    c::inits = []
  c::inits.push init
  
  c::init = (conf) ->
    m.call(this, conf) for m in @inits

# use 'observable class MyObservable' to mix in
# observable features
window.observable = (c) ->
  setup_init c, (config) ->
    @_dispatcher = d3.dispatch(config.events...)
    
    # auto incrementing ids are used to avoid overwriting listeners
    @_next_id = 0
    
  # register a callback on the given event type, with an optional namespace
  # syntax: event_type.namespace
  # null as callback unbinds the listener
  c::on = (event_type_ns, callback) ->
    splitted_event_type_ns = event_type_ns.split('.')
    event_type = splitted_event_type_ns[0]
    if splitted_event_type_ns.length > 1
      namespace = splitted_event_type_ns[1]
    else
      # use an automatic ID
      namespace = @_next_id
      @_next_id += 1
      
    event_type_full = event_type + '.' + namespace
    @_dispatcher.on event_type_full, callback
    
    # callers who want to unbind or overwrite the created listener have to store the full event type
    return event_type_full
    
  # trigger an event of the given type and pass the given args
  c::trigger = (event_type, args...) ->
    @_dispatcher.apply(event_type, this, args)
    return this
  
  return c
  
# use 'observer class MyObservable' to mix in
# observer features
window.observer = (c) ->
  setup_init c, () ->
    @_bindings = []
    
  c::listen_to = (observed, event, cb) ->
    @_bindings.push
      observed: observed
      event_type: observed.on event, cb
    
  c::stop_listening = () ->
    # unbind all listeners
    @_bindings.forEach (l) =>
      l.observed.on l.event_type, null
    
  return c


# GUI component
window.View = class View
  constructor: (conf) ->
    # div is default
    if not conf.tag?
      conf.tag = 'div'
      
    # both DOM and d3 element references
    @el = document.createElement(conf.tag)
    @d3el = d3.select(@el)
    
    # set a CSS class equal to the class name of the view
    # WARNING this is not supported on IE
    # if needed, this polyfill can be used:
    # https://github.com/JamesMGreene/Function.name
    @d3el.classed this.constructor.name, true
    
    # automatically append this view to the given parent, if any
    if conf.parent?
      @append_to(conf.parent, conf.prepend)
      
  # append this view to a parent view or node
  append_to: (parent, prepend) ->
    if parent.el? # Backbone-style view
      p_el = parent.el
    else # selector or d3 selection or dom node
      if parent.node? # d3 selection
        p_el = parent.node()
      else # selector or dom node
        p_el = d3.select(parent).node()
      
    if prepend
      p_el.insertBefore @el, p_el.firstChild
    else
      p_el.appendChild @el

  # compute width and height
  compute_size: () ->
    @width = @el.getBoundingClientRect().width
    @height = @el.getBoundingClientRect().height
    
