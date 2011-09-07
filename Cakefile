exec = require('child_process').exec

task 'build', 'src/ --> lib/', ->
  # .coffee --> .js
  exec 'coffee -co lib src', (err, stdout, stderr) ->
    if err
      console.log stdout
      console.log stderr
      throw new Error "Error while compiling .coffee to .js"
      
task 'watch', 'test using nap.watch', ->
  require('./src/nap.coffee').watch require('./spec/stubs/assets_stub5.coffee'), 'spec/fixtures/assets'