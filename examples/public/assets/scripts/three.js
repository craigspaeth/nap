(function() {
  alert('Refrigerator');

  setTimeout((function() {
    var el;
    el = document.getElementById('container');
    return el.innerHTML = JST['make_it_rain']();
  }), 500);

}).call(this);
