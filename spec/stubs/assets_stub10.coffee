@js =
 
  preManipulate: 
      '*': [( (file) -> file += 'foo' )]
  
  foo: [
    'spec/fixtures/js/foo.js'
    'spec/fixtures/js/bar.js'
  ]