# Library of manipulator functions
_ = require 'underscore'

# Pre-manipulators
@compileCoffeescript = (contents, filename) -> 
  if filename? and filename.match(/.coffee$/)?
    require('coffee-script').compile contents
  else
    contents
@compileStylus = (contents, filename) ->
  if filename? and filename.match(/.styl$/)?
    css = ''
    require('stylus').render contents, (err, out) -> throw err if err; css = out
    css
  else
    contents 
@packageJST = (contents, filename) ->
  tmplDirname = 'templates/'
  ext = _.last filename.split('.')
  escapedFile = contents.replace(/\n+/g, '\\n').replace /"/g, '\\"'
  if filename? and filename.indexOf(tmplDirname) isnt -1
    filename = filename.substr(filename.indexOf(tmplDirname) + tmplDirname.length)
  filename = filename.replace('.' + ext, '')
  "window.JST[\"#{filename}\"] = JSTCompile(\"#{escapedFile}\");\n"

# Post-manipulators
@prependJST = (compilerFunctionStr) -> 
  return (contents, filename) ->
    str = 'window.JST = {};\n'
    str += "window.JSTCompile = #{compilerFunctionStr};\n"
    str + contents
@ugilfyJS = (contents, filename) ->
  jsp = require("uglify-js").parser
  pro = require("uglify-js").uglify
  ast = jsp.parse contents
  ast = pro.ast_mangle(ast)
  ast = pro.ast_squeeze(ast)
  pro.gen_code(ast)
@yuiCssMin = (contents, filename) -> require('../deps/yui_cssmin.js').minify contents