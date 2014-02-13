JST['make_it_rain'] = function template(locals) {
var jade_debug = [{ lineno: 1, filename: undefined }];
try {
var buf = [];
var jade_mixins = {};
var locals_ = (locals || {}),undefined = locals_.undefined;
jade_debug.unshift({ lineno: 0, filename: jade_debug[0].filename });
jade_debug.unshift({ lineno: 1, filename: jade_debug[0].filename });
// iterate new Array(100)
;(function(){
  var $$obj = new Array(100);
  if ('number' == typeof $$obj.length) {

    for (var $index = 0, $$l = $$obj.length; $index < $$l; $index++) {
      var i = $$obj[$index];

jade_debug.unshift({ lineno: 1, filename: jade_debug[0].filename });
jade_debug.unshift({ lineno: 2, filename: jade_debug[0].filename });
buf.push("<h1>");
jade_debug.unshift({ lineno: undefined, filename: jade_debug[0].filename });
jade_debug.unshift({ lineno: 2, filename: jade_debug[0].filename });
buf.push("(╯°□°)╯︵ ┻━┻ ︵ ╯(°□° ╯)");
jade_debug.shift();
jade_debug.shift();
buf.push("</h1>");
jade_debug.shift();
jade_debug.shift();
    }

  } else {
    var $$l = 0;
    for (var $index in $$obj) {
      $$l++;      var i = $$obj[$index];

jade_debug.unshift({ lineno: 1, filename: jade_debug[0].filename });
jade_debug.unshift({ lineno: 2, filename: jade_debug[0].filename });
buf.push("<h1>");
jade_debug.unshift({ lineno: undefined, filename: jade_debug[0].filename });
jade_debug.unshift({ lineno: 2, filename: jade_debug[0].filename });
buf.push("(╯°□°)╯︵ ┻━┻ ︵ ╯(°□° ╯)");
jade_debug.shift();
jade_debug.shift();
buf.push("</h1>");
jade_debug.shift();
jade_debug.shift();
    }

  }
}).call(this);

jade_debug.shift();
jade_debug.shift();;return buf.join("");
} catch (err) {
  jade.rethrow(err, jade_debug[0].filename, jade_debug[0].lineno, "for i in new Array(100)\n  h1 (╯°□°)╯︵ ┻━┻ ︵ ╯(°□° ╯)");
}
};
