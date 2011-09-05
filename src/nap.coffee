# Module dependencies
fileUtil = require 'file'
_ = require 'underscore'
fs = require 'fs'

# Library of manipulator functions
@compileCoffeescript = (file) -> require('coffee-script').compile(file)
@compileStylus = (file) -> 
  css = ''
  require('stylus').render file, (err, out) -> throw err if err; css = out
  css
@packageJST = (file, path) ->
  tmplDirname = 'templates/'
  ext = _.last path.split('.')
  escapedFile = file.replace(/\n+/g, '\\n').replace /"/g, '\\"'
  if path.indexOf(tmplDirname) isnt -1
    path = path.substr(path.indexOf(tmplDirname) + tmplDirname.length)
  path = path.replace('.' + ext, '')
  "window.JST[\"#{path}\"] = JSTCompile(\"#{escapedFile}\");"
@ugilfyJS = (file) ->
  jsp = require("uglify-js").parser
  pro = require("uglify-js").uglify
  ast = jsp.parse file
  ast = pro.ast_mangle(ast)
  ast = pro.ast_squeeze(ast)
  pro.gen_code(ast)
@yuiCssMin = (file) -> require('../deps/yui_cssmin.js').minify file
  
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
compilePackage = (name, files, dir, manipulators, options = { env: process.env.NODE_ENV || 'development' }) ->
  
  # Adjust files for wildcards
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
          newFiles.push(root + file) if file.match(new RegExp ext + '$')?
      files.splice fileIndex, 1, newFiles...
    
    # If there is a wildcard in the /* form then remove it and splice in all the
    # files one directory deep
    else if file? and file.indexOf('/*') isnt -1
      root = file.split('/*')[0]
      ext = file.split('/*')[1]
      newFiles = []
      for file in fs.readdirSync(root)
        if file.indexOf('.') isnt -1 and file.match(new RegExp ext + '$')?
          newFiles.push(root + '/' + file)
      files.splice fileIndex, 1, newFiles...

  # Map files contents
  fileStrs = (fs.readFileSync(file).toString() for file in files)

  # Run any pre manipulators on each of the files
  for i, file of files
    if manipulators? and manipulators.pre? and manipulators.pre[options.env]?
      for manipulator in manipulators.pre[options.env]
        fileStrs[i] = manipulator(fileStrs[i], file)

  # Concatenate the files
  concatFileStr = (file for file in fileStrs).join '\n'

  # Run any post manipulators on the concatenated file
  if manipulators? and manipulators.post? and manipulators.post[options.env]?
    for manipulator in manipulators.post[options.env]
      concatFileStr = manipulator(concatFileStr)

  fs.writeFileSync "#{dir}/#{name}", concatFileStr