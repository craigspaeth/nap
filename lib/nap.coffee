# Dependencies
fs = require 'fs'
path = require 'path'
exec = require('child_process').exec
coffee = require 'coffee-script'
styl = require 'stylus'
nib = require 'nib'
jade = require 'jade'
jadeRuntime = fs.readFileSync(path.resolve __dirname, '../deps/jade.runtime.js').toString()
sqwish = require 'sqwish'
uglifyjs = require "uglify-js"
_ = require 'underscore'
_.mixin require 'underscore.string'
mkdirp = require 'mkdirp'
fileUtil = require 'file'

# The initial configuration function. Pass it options such as `assets` to let nap determine which
# files to put together in packages, among others.
# 
# @param {Object} options A hash of configuration options
# @return {Function} Returns itself for chainability

module.exports = (options = {}) =>

  # Config variables
  @assets = options.assets
  @publicDir = options.publicDir ? '/public'
  @mode = options.mode ? do ->
    switch process.env.NODE_ENV
      when 'staging' then 'production'
      when 'production' then 'production'
      else 'development'
  @cdnUrl = if options.cdnUrl? then options.cdnUrl.replace /\/$/, '' else undefined
  @embedImages = options.embedImages ? false
  @embedFonts = options.embedFonts ? false
  @gzip = options.gzip ? false
  @_tmplFilePrefix = 'window.JST = {};\n'
  @_assetsDir = '/assets'
  @_outputDir = path.normalize @publicDir + @_assetsDir
  
  unless @assets?
    throw new Error "You must specify an 'assets' hash with keys 'js', 'css', or 'jst'"
  
  unless path.existsSync process.cwd() + @publicDir
    throw new Error "The directory #{@publicDir} doesn't exist"
    
  unless path.existsSync process.cwd() + @_outputDir
    fs.mkdirSync process.cwd() + @_outputDir, 0777

  @

# Run js pre-processors & output the files in dev.
# Return link tags pointing to processed package or individual files.
# 
# @param {String} pkg The name of the package to output
# @return {String} Script tag pointing to the ouput package(s)

module.exports.js = (pkg, gzip = @gzip) =>
  throw new Error "Cannot find package '#{pkg}'" unless @assets.js[pkg]?
  
  if @mode is 'production'
    src = (@cdnUrl ? @_assetsDir) + '/' + pkg + '.js'
    src += '.jgz' if gzip
    return "<script src='#{src}' type='text/javascript'></script>"
  
  output = ''
  for filename, contents of precompile pkg, 'js'
    writeFile filename, contents
    output += "<script src='#{@_assetsDir}/#{filename}' type='text/javascript'></script>"
  output
  
# Run css pre-processors & output the packages in dev.
# Return link tags pointing to processed package or individual files.
# 
# @param {String} pkg The name of the package to output
# @return {String} Style tag pointing to the ouput package(s)

module.exports.css = (pkg, gzip = @gzip) =>
  throw new Error "Cannot find package '#{pkg}'" unless @assets.css[pkg]?
  
  if @mode is 'production'
    src = (@cdnUrl ? @_assetsDir) + '/' + pkg + '.css'
    src += '.cgz' if gzip
    return "<link href='#{src}' rel='stylesheet' type='text/css'>"
  
  output = ''
  for filename, contents of precompile pkg, 'css'
    writeFile filename, embedFiles filename, contents
    output += "<link href='#{@_assetsDir}/#{filename}' rel='stylesheet' type='text/css'>"
  output
  
# Compile the templates into JST['file/path'] : functionString pairs in dev.
# Return the script tag pointing to the file.
# 
# @param {String} pkg The name of the package to output
# @return {String} Script tag pointing to the ouput JST script file

module.exports.jst = (pkg, gzip = @gzip) =>
  throw new Error "Cannot find package '#{pkg}'" unless @assets.jst[pkg]?
  
  if @mode is 'production'
    src = (@cdnUrl ? @_assetsDir) + '/' + pkg + '.jst.js'
    src += '.jgz' if gzip
    return "<script src='#{src}' type='text/javascript'></script>"
  
  fs.writeFileSync (process.cwd() + @_outputDir + '/' + pkg + '.jst.js'), generateJSTs pkg
  fs.writeFileSync (process.cwd() + @_outputDir + '/nap-templates-prefix.js'), @_tmplFilePrefix
  
  """
  <script src='#{@_assetsDir}/nap-templates-prefix.js' type='text/javascript'></script>
  <script src='#{@_assetsDir}/#{pkg}.jst.js' type='text/javascript'></script>
  """

# Runs through all of the asset packages. Concatenates, minifies, and gzips them. Then outputs
# the final packages to the outputDir. (To be run once during the build step for production)

module.exports.package = (callback) =>
  
  total = _.reduce (_.values(pkgs).length for key, pkgs of @assets), (memo, num) ->
    memo + num
  finishCallback = _.after total, -> callback() if callback?
  
  if @assets.js?
    for pkg, files of @assets.js
      contents = (contents for filename, contents of precompile pkg, 'js').join('')
      contents = uglify contents if @mode is 'production'
      writeFile pkg + '.js', contents
      gzipPkg contents, pkg + '.js', finishCallback
      total++
      
  if @assets.css?
    for pkg, files of @assets.css 
      contents = (embedFiles(filename, contents) for filename, contents of precompile pkg, 'css').join('')
      contents = sqwish.minify contents if @mode is 'production'
      writeFile pkg + '.css', contents
      gzipPkg contents, pkg + '.css', finishCallback
      total++
      
  if @assets.jst?
    for pkg, files of @assets.jst
      contents = @_tmplFilePrefix
      contents += generateJSTs pkg
      contents = uglify contents if @mode is 'production'
      writeFile pkg + '.jst.js', contents
      gzipPkg contents, pkg + '.jst.js', finishCallback
      total++
      
# Gzips a package (used in nap.package to DRY things up)
# 
# @param {String} contents The new file contents
# @param {String} filename The name of the new file
  
gzipPkg = (contents, filename, callback) =>
  if @gzip
    file = "#{process.cwd() + @_outputDir + '/'}#{filename}"
    ext = if _.endsWith filename, '.js' then '.jgz' else '.cgz'
    exec "gzip #{file}", (err, stdout, stderr) ->
      console.log stderr if stderr?
      fs.renameSync file + '.gz', file + ext
      writeFile filename, contents
      callback()
  else
    callback()
  
# Run any pre-processors on a package, and return a hash of { filename: compiledContents }
# 
# @param {String} pkg The name of the package to precompile
# @param {String} type Either 'js' or 'css'
# @return {Object} A { filename: compiledContents } hash 

precompile = (pkg, type) =>
  
  hash = {}
  
  for filename in replaceWildcards @assets[type][pkg]
    contents = fs.readFileSync(process.cwd() + '/' + filename).toString()
    
    if filename.match /\.coffee$/
      contents = coffee.compile contents
    
    if filename.match /\.styl$/
      styl(contents)
        .set('filename', process.cwd() + '/' + filename)
        .use(nib())
        .render (err, out) ->
          throw(err) if err
          contents = out
    
    outputFilename = filename.replace /\.[^.]*$/, '' + '.' + type
    hash[outputFilename] = contents
  hash

# A function that takes a template string and parses it into function meant to be run on the 
# client side.
# 
# @param {String} str Contents of the template string to be parsed
# @param {String} engine The name of the templating engine
# @return {Function} Accepts template vars and is meant to be run on the client-side

parseTmplToFn = (str, engine) =>
  switch engine
    when 'jade'
      if @_tmplFilePrefix.indexOf jadeRuntime is -1
        @_tmplFilePrefix = jadeRuntime + "\n" + @_tmplFilePrefix
      return jade.compile(str, { client: true, compileDebug: true })


# Creates a file with template functions packed into a JST namespace
# 
# @param {String} pkg The package name to generate from
# @return {String} The new JST file contents

module.exports.generateJSTs = generateJSTs = (pkg) =>
  
  tmplFileContents = ''
  
  for filename in replaceWildcards @assets.jst[pkg]
    
    switch _.last filename.split('.')
      when 'jade' then engine = 'jade'
    
    contents = fs.readFileSync(process.cwd() + '/' + filename).toString()
    contents = parseTmplToFn(contents, engine).toString()
    
    if filename.indexOf('templates') > -1
      namespace = filename.split('templates')[-1..][0].replace /^\/|\..*/g, ''
    else
      namespace = filename.split('/')[-1..][0].replace /^\/|\..*/g, ''
    
    tmplFileContents += "JST['#{namespace}'] = #{contents};\n"
  tmplFileContents

# Given a filename creates the sub directories it's in if it doesn't exist. And write it to the
# output path.
# 
# @param {String} filename Filename of the css/js/jst file to be output
# @param {String} contents Contents of the file to be output
# @return {String} The new full directory of the output file

writeFile = (filename, contents) =>
  dir = process.cwd() + @_outputDir + '/' + filename
  p = path.dirname dir
  mkdirp.sync p, 0755 unless path.exists p
  fs.writeFileSync dir, contents ? ''

# Runs uglify js on a string of javascript
# 
# @param {String} str String of js to be uglified
# @return {String} str Minifed js string

uglify = (str) ->
  jsp = uglifyjs.parser
  pro = uglifyjs.uglify
  ast = jsp.parse str
  ast = pro.ast_mangle(ast)
  ast = pro.ast_squeeze(ast)
  pro.gen_code(ast)

# Given the contents of a css file, replace references to url() with base64 embedded image
# 
# @param {String} str The filename to replace
# @param {String} str The CSS string to replace url()'s with
# @return {String} The CSS string with the url()'s replaced

embedFiles = (filename, contents) =>
  
  endsWithEmbed = _.endsWith path.basename(filename).split('.')[0], '_embed'
  return contents if not contents? or contents is '' or not endsWithEmbed
  
  # Table of mime types depending on file extension
  mimes = {}
  if @embedImages
    mimes = _.extend {
      '.gif' : 'image/gif'
      '.png' : 'image/png'
      '.jpg' : 'image/jpeg'
      '.jpeg': 'image/jpeg'
      '.svg' : 'image/svg+xml'
    }, mimes
  
  if @embedFonts
    mimes = _.extend {
      '.ttf': 'font/truetype;charset=utf-8'
      '.woff': 'font/woff;charset=utf-8'
      '.svg' : 'image/svg+xml'
    }, mimes
  
  return contents if _.isEmpty mimes
  
  offset = 0
  offsetContents = contents.substring(offset, contents.length)
  
  return contents unless offsetContents.match(/url/g)?
  
  # While there are urls in the contents + offset replace it with base 64
  # If that url() doesn't point to an existing file then skip it by pointing the
  # offset ahead of it
  for i in [0..offsetContents.match(/url/g).length]

    start = offsetContents.indexOf('url(') + 4 + offset
    end = contents.substring(start, contents.length).indexOf(')') + start
    filename = _.trim _.trim(contents.substring(start, end), '"'), "'"
    filename = process.cwd() + @publicDir + '/' + filename.replace /^\//, ''
    mime = mimes[path.extname filename]
    
    if mime?    
      if path.existsSync filename
        base64Str = fs.readFileSync(filename).toString('base64')
      
        newUrl = "data:#{mime};base64,#{base64Str}"
        contents = _.splice(contents, start, end - start, newUrl)
        end = start + newUrl.length + 4
      else
        throw new Error 'Tried to embed data-uri, but could not find file ' + filename
    else
      end += 4
    
    offset = end
    offsetContents = contents.substring(offset, contents.length)

  return contents

# Given a list of file strings, replaces the wild cards with the appropriate matches
# 
# @param {Array} files
# @return {Array} Filename strings

replaceWildcards = (files) ->
  files = (process.cwd().replace(/\/$/, '') + '/' + file.replace /^\//, '' for file in files)
  files = (for file in files
    if file.indexOf('/*') isnt -1 then findWildcards(file) else file)
  files = _.uniq _.flatten files
  files = (file.replace(process.cwd(), '').replace(/^\//, '') for file in files)
  files

# Given a filename such as /fld/**/* return all recursive files
# or given a filename such as /fld/* return all files one directory deep.
# Limit by extension via /fld/**/*.coffee
# 
# @param {String} filename
# @return {Array} An array of file path strings

findWildcards = (filename) ->
  
  files = []
  
  # If there is a wildcard in the /**/* form of a file then remove it and
  # splice in all files recursively in that directory
  if filename? and filename.indexOf('**/*') isnt -1
    root = filename.split('**/*')[0]
    ext = filename.split('**/*')[1]
    fileUtil.walkSync root, (root, flds, fls) ->
      root = (if root.charAt(root.length - 1) is '/' then root else root + '/')
      for file in fls
        if file.match(new RegExp ext + '$')? and _.indexOf(files, root + file) is -1
          files.push(root + file)

  # If there is a wildcard in the /* form then remove it and splice in all the
  # files one directory deep
  else if filename? and filename.indexOf('/*') isnt -1
    root = filename.split('/*')[0]
    ext = filename.split('/*')[1]
    for file in fs.readdirSync(root)
      if file.indexOf('.') isnt -1 and file.match(new RegExp ext + '$')? and _.indexOf(files, root + '/' + file) is -1
        files.push(root + '/' + file)
        
  files