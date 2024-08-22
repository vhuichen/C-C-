
var events = require('events');

var eventsEmitter = new events.EventEmitter();

eventsEmitter.on('event1', function(data) {
  console.log('event1 emitted with data:'+ data);
});

setTimeout(() => {
    eventsEmitter.emit('event1', 'Hello World');
}, 1000);
