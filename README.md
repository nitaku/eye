# eye
Observable pattern mixins and View class for coffeescript

Disclaimer: eye is designed for internal use at WAFI IIT CNR.

## API

### Observable mixin
You can make any coffeescript class capable of triggering events by defining it like this:
```coffeescript
observable class MyClass
  constructor: () ->
    @init
      events: ['my_event_a', 'my_event_b']
```
From now on, instances of your class will expose the following methdos:

#### observable.on(_event_name_, _callback_)
This method binds _callback_ (a function) to the event with the specified _event_name_ (a string). Whenever that event is triggered, the given callback is executed.

It is possible to bind more than one callback to the same event by calling _observable.on_ many times (the binding is not overwritten).

The method returns an identifier for the binding that has just been created. (To Be Done: streamline this behavior and add unbind capabilities).

#### observable.trigger(_event_name_)
This method triggers the _event_name_ event. It is always necessary to call _observable.trigger_ explicitly, i.e., no attempts to automatically trigger events are made by _eye_. (To Be Done: passing parameters - discouraged)
