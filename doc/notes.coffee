# MIT Liscense
# TDD, Awesome documentation, Cakefile sweetness, Changelog, Branch versions (initially go crazy while in 0.0.x)
# First set up asset packaging without minifying/compressing/image embedding/embedded fonts
# Nap manipulators have logic that skips or fixes certain things depending on user-agents (which means being able to put together
# various packages for things like embedded images, or embedding CSS conditionals?)
# Packages up anything not labeled as one of the manipulators
# 
@js =
  
  manipulators:
    'development': 
      preManipulate: [nap.compileCoffeescript]
    'production': 
      preManipulate: [nap.compileCoffeescript]
      postManipulate: [nap.uglifyJS, nap.gzip]
  
  vendor: ['app/client/vendor/*.js']

  backbone: [
    'app/client/models/**/*.coffee'
    'app/client/views/**/*.coffee'
    'app/client/collections/*.coffee'
    /^/
  ] 

@css =
  
  manipulators:
    'development': 
      postManipulate: [nap.compileStylus]
    'production': 
      postManipulate: [nap.compileStylus, nap.embedImages, nap.embedFonts, nap.yuiCompressor, nap.gzip]
  
  splash: [
    'app/stylesheets/splash.stylus'
    'app/stylesheets/icons.stylus'
  ]
  
@jst =
  
  manipulators: 
    'development': 
      preManipulate: [nap.packageJSTs]
    'production':
      preManipulate: [nap.packageJSTs]
      postManipulate: [nap.gzip]
    
  all: ['app/templates/**/*.jade']

# Send your obj to nap.package and it will clear the directory then run through 
# each package and output the compiled files to the directory.
nap.package assets, 'public/assets'

# Same as package, but will watch for file changes in the packages and only 
# regenerate that package
nap.watch assets, 'public/assets'

# For production I want to package the assets and push them to a CDN.
# Attach this hook in a cake task, or git hook. Whatever runs when something
# is 'pushed to production'. This will package the assets, delete the old assets, and upload
# the new ones.
nap.packageToS3 assets, 'public/assets' #, S3INFO