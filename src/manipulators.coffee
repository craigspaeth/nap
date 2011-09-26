### 
Library of manipulator functions.
###
_ = require 'underscore'
stylus = require 'stylus'
nib = require 'nib'

###
Pre-manipulators

Pre-manipulators are passed each individual file before it gets merged in to one file.

@param {String} contents The contents of the file
@param {String} filename
@return {String} The manipulated contents 
###

@compileCoffeescript = (contents, filename) -> 
  if filename? and filename.match(/.coffee$/)?
    require('coffee-script').compile contents
  else
    contents
    
@compileStylus = (contents, filename) ->
  if filename? and filename.match(/.styl$/)?
    css = ''
    stylus(contents)
      .set('filename', filename)
      .import(nib.path + '/nib/index.styl')
      .render (err, out) -> throw err if err; css = out
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

###
Post-manipulators

Post-manipulators are passed the merged files.

@param {String} contents The contents of the merged files
@return {String} The manipulated contents
###

@prependJST = (compilerFunctionStr) -> 
  return (contents) ->
    str = 'window.JST = {};\n'
    str += "window.JSTCompile = #{compilerFunctionStr};\n"
    str + contents

@ugilfyJS = (contents) ->
  jsp = require("uglify-js").parser
  pro = require("uglify-js").uglify
  ast = jsp.parse contents
  ast = pro.ast_mangle(ast)
  ast = pro.ast_squeeze(ast)
  pro.gen_code(ast)

@yuiCssMin = (contents) -> require('../deps/yui_cssmin.js').minify contents