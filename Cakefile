task 'build', 'src/ --> lib/', ->
  # .coffee --> .js
  exec 'coffee -co lib src', (err, stdout, stderr) ->
    if err
      console.log stdout
      console.log stderr
      throw new Error "Error while compiling .coffee to .js"
  
task 'testpackage', 'runs a package of the test', ->
  require(__dirname + '/src/nap.coffee').package require(__dirname + '/spec/stubs/assets_stub2.coffee'), __dirname + '/spec/fixtures/assets'
  
task 'testuglify', ->
  jsp = require("uglify-js").parser
  pro = require("uglify-js").uglify
  orig_code = require('fs').readFileSync __dirname + '/jquery.js'
  ast = jsp.parse(orig_code + '')
  ast = pro.ast_mangle(ast)
  ast = pro.ast_squeeze(ast)
  final_code = pro.gen_code(ast)
  console.log final_code