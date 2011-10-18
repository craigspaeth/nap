### 
Library of manipulator functions.
###
_ = require 'underscore'
_.mixin(require('underscore.string'))
fs = require 'fs'
path = require 'path'

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
    require('stylus')(contents)
      .set('filename', filename)
      .use(require('nib')())
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

@embedImages = (imgDir) ->
  
  # Table of mime types depending on file extension
  mimes =
    '.gif' : 'image/gif'
    '.png' : 'image/png'
    '.jpg' : 'image/jpeg'
    '.jpeg': 'image/jpeg'
    '.svg' : 'image/svg+xml'
  
  return (contents) ->
    
    # While there are urls in the contents + offset replace it with base 64
    # If that url() doesn't point to an existing file then skip it by pointing the
    # offset ahead of it
    offset = 0
    offsetContents = contents.substring(offset, contents.length)
    while offsetContents.indexOf('url(') isnt -1
      
      start = offsetContents.indexOf('url(') + 4 + offset
      end = contents.substring(start, contents.length).indexOf(')') + start
      filename = imgDir + _.trim _.trim(contents.substring(start, end), '"'), "'"
      
      if path.existsSync filename
        base64Str = fs.readFileSync(filename).toString('base64')
        mime = mimes[path.extname filename]
        newUrl = "data:#{mime};base64,#{base64Str}"
        contents = _.splice(contents, start, end - start, newUrl)
        end = start + newUrl.length + 4
      else
        console.log 'NAP: Could not find file ' + filename
      
      offset = end
      offsetContents = contents.substring(offset, contents.length)
      
    return contents