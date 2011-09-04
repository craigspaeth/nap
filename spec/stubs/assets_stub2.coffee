@js =
 
  preManipulate: 
      'development': [( (file) -> file += 'foo' )]
      'production': [( (file) -> file += 'bar' )]
  
  foo: [
    'spec/fixtures/js/foo.js'
    'spec/fixtures/js/bar.js'
  ]