@js =
 
  postManipulate: 
      'development': [( (file) -> file += 'baz' )]
      'production': [( (file) -> file += 'qux' )]
  
  foo: [
    'spec/fixtures/js/foo.js'
    'spec/fixtures/js/bar.js'
  ]