task 'build', 'src/ --> lib/', ->
  # .coffee --> .js
  exec 'coffee -co lib src', (err, stdout, stderr) ->
    if err
      console.log stdout
      console.log stderr
      throw new Error "Error while compiling .coffee to .js"
  
task 'testpackage', 'runs a package of the test', ->
  require(__dirname + '/src/nap.coffee').package require(__dirname + '/spec/helpers/assets_stub2.coffee'), __dirname + '/spec/fixtures/assets' 