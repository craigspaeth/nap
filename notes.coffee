# MIT Liscense
# TDD, Awesome documentation, Cakefile sweetness, Changelog, Branch versions (initially go crazy while in 0.0x)
# First set up asset packaging without minifying/compressing/image embedding/embedded fonts

@outputDir = 'public/assets'

@javascripts =

  vendor: ['app/client/vendor/*.js']

  backbone: [
    'app/client/models/*.coffee'
    'app/client/views/*.coffee'
    'app/client/collections/*.coffee'
  ]
  
if env is 'development'
  @javascripts.compilers = [nap.compileCoffeescript]
else
  @javascripts.compilers = [nap.compileCoffeescript, nap.uglifyJS, nap.gzip]

@stylesheets =
  
  splash: [
    'app/stylesheets/splash.stylus'
    'app/stylesheets/icons.styllus'
  ]

if env is 'development'
  @stylesheets.compilers = [nap.compileStylus, nap.embedImages, nap.embedFonts, nap.gzip]
else
  @stylesheets.compilers = [nap.compileStylus, nap.embedImages, nap.embedFonts, nap.yuiCompressor, nap.gzip]
  
@templates =
  
  compilers: [nap.packageJST, nap.gzip]

# Send your obj to nap.package and it will run through each package and output
# the compiled files to the directory.
nap = require 'nap'
nap.package assets