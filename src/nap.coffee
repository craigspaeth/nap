# Module dependencies
fileUtil = require 'file'
_ = require 'underscore'
fs = require 'fs'

# Library of manipulator functions

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
@prependJST = (contents, filename) ->
  str = 'window.JST = {};\n'
  msg = 'You must override JSTCompile with your own template compiler function.'
  str += "window.JSTCompile = function() { throw new Error('#{msg}'}) };\n"
  str + contents
@ugilfyJS = (contents, filename) ->
  jsp = require("uglify-js").parser
  pro = require("uglify-js").uglify
  ast = jsp.parse contents
  ast = pro.ast_mangle(ast)
  ast = pro.ast_squeeze(ast)
  pro.gen_code(ast)
@yuiCssMin = (contents, filename) -> require('../deps/yui_cssmin.js').minify contents
  
# Given a well formatted assets object, package will concatenate the files and 
# run manipulators in the order provided. Then output the concatenated package
# to the given directory.
@package = (assets, dir) ->
  for extension, keys of assets
    for packageName, files of splitAssetGroup(keys).packages
      compilePackage packageName + '.' + extension, files, dir, splitAssetGroup(keys).manipulators

# Given a well formatted assets object, package will watch for any file changes in the
# one of the packages and re-compile that package.
@watch = (assets, dir) ->
  
  # Put a watcher on every file. If that file changes, compile it's package
  for extension, keys of assets
    for packageName, files of splitAssetGroup(keys).packages
      for file in files
        fs.watchFile file, (curr, prev) ->
          compilePackage packageName + '.' + extension, files, dir, splitAssetGroup(keys).manipulators
        
# Given an asset group split up it's packages and manipulators
splitAssetGroup = (group) ->
  packages = _.clone group
  manipulators =
    pre: group.preManipulate
    post: group.postManipulate  
  delete packages['preManipulate']
  delete packages['postManipulate']
  packages: packages, manipulators: manipulators

# Given a package name and list of file names concatenate the files and run the given
# manipulators in the order provided. Then output the concatenated package to the given directory.
compilePackage = (name, files, dir, manipulators) ->
  
  env = process.env.NODE_ENV || 'development'
  
  # Adjust files for wildcards
  hasWildcards = ->
    for file in files
      return true if file.indexOf('/*') isnt -1
    false
  while hasWildcards()
    
    for fileIndex, file of files
    
      # If there is a wildcard in the /**/* form of a file then remove it and
      # splice in all files recursively in that directory
      if file? and file.indexOf('**/*') isnt -1
        root = file.split('**/*')[0]
        ext = file.split('**/*')[1]
        newFiles = []
        fileUtil.walkSync root, (root, flds, fls) ->
          root = (if root.charAt(root.length - 1) is '/' then root else root + '/')
          for file in fls
            if file.match(new RegExp ext + '$')? and _.indexOf(files, root + file) is -1
              newFiles.push(root + file)
        files.splice(fileIndex, 1, newFiles...)
    
      # If there is a wildcard in the /* form then remove it and splice in all the
      # files one directory deep
      if file? and file.indexOf('/*') isnt -1 and file.indexOf('**/*') is -1
        root = file.split('/*')[0]
        ext = file.split('/*')[1]
        newFiles = []
        for file in fs.readdirSync(root)
          if file.indexOf('.') isnt -1 and file.match(new RegExp ext + '$')? and _.indexOf(files, root + '/' + file) is -1
            newFiles.push(root + '/' + file)
        files.splice(fileIndex, 1, newFiles...)

  # Map files contents
  # console.log files
  fileStrs = (fs.readFileSync(file).toString() for file in files)

  # Run any pre manipulators on each of the files
  for i, file of files
    if manipulators? and manipulators.pre? and manipulators.pre[env]?
      for manipulator in manipulators.pre[env]
        fileStrs[i] = manipulator(fileStrs[i], file)

  # Concatenate the files
  concatFileStr = (file for file in fileStrs).join '\n'

  # Run any post manipulators on the concatenated file
  if manipulators? and manipulators.post? and manipulators.post[env]?
    for manipulator in manipulators.post[env]
      concatFileStr = manipulator(concatFileStr)

  fs.writeFileSync "#{dir}/#{name}", concatFileStr