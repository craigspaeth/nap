alert('Haikus are easy');;
alert('But sometimes they don’t make sense');;
(function() {
  alert('Refrigerator');

  setTimeout((function() {
    var el;
    el = document.getElementById('container');
    return el.innerHTML = JST['make_it_rain']();
  }), 500);

}).call(this);
