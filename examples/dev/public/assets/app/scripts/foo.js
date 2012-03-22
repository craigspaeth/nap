(function() {

  $(function() {
    return $('body').append($(JST['hello']({
      world: 'Earth'
    })));
  });

}).call(this);
