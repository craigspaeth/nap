nap = require './lib/nap'

# Initializing

start = new Date().getTime()
for i in [0..100]
  nap
    assets:
      js:
        foo: ['/test/fixtures/1/**/*.js', '/test/fixtures/1/**/*.coffee']
      css:
        bar: ['/test/fixtures/1/**/*.css', '/test/fixtures/1/**/*.styl']
      jst:
        baz: ['/test/fixtures/1/**/*.jade', '/test/fixtures/templates/**/*.jade']
      
console.log "Initializing 100x: " + (new Date().getTime() - start)

# Generating JSTs

start = new Date().getTime()
nap
  assets:
    js:
      foo: ['/test/fixtures/1/**/*.js', '/test/fixtures/1/**/*.coffee']
    css:
      bar: ['/test/fixtures/1/**/*.css', '/test/fixtures/1/**/*.styl']
    jst:
      baz: ['/test/fixtures/1/**/*.jade', '/test/fixtures/templates/**/*.jade']

for i in [0..1000]
  nap.generateJSTs 'baz'
      
console.log "Generating JSTs 1000x: " + (new Date().getTime() - start)