JST['foo'] = function anonymous(locals, attrs, escape, rethrow) {
var attrs = jade.attrs, escape = jade.escape, rethrow = jade.rethrow;
var __ = [{ lineno: 1, filename: undefined }];
try {
var buf = [];
with (locals || {}) {
var interp;
__.unshift({ lineno: 1, filename: __[0].filename });
__.unshift({ lineno: 1, filename: __[0].filename });
buf.push('<h2>Hello ' + escape((interp = world) == null ? '' : interp) + '');
__.unshift({ lineno: undefined, filename: __[0].filename });
__.shift();
buf.push('</h2>');
__.shift();
__.shift();
}
return buf.join("");
} catch (err) {
  rethrow(err, __[0].filename, __[0].lineno);
}
};
