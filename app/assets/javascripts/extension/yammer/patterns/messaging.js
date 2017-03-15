/*

Horizon - a mobile web app view management framework
Author - Alex Grande

*/

window.recognize = window.recognize || {};
window.recognize.message = window.recognize.message || {
  eventMap: {},
    fire: function (eventName, data) {
        if (typeof this.eventMap[eventName] === "function") {
            this.eventMap[eventName](data);
        }
    },
    subscribe: function (eventName, fn, replace) {
        if (typeof this.eventMap[eventName] === "undefined" || replace) {
            this.eventMap[eventName] = fn;
        } else {
            var oldFunction = this.eventMap[eventName];
            this.eventMap[eventName] = function (data) {
                if(typeof data !== "undefined") {
                    oldFunction(data);
                    fn(data);
                } else {
                    oldFunction();
                    fn();
                }
            };
        }
    }
};