# Module dependencies
fileUtil = require 'file'
_ = require 'underscore'
fs = require 'fs'
sentry = require 'sentry'

# Attach manipulators to nap
@[name] = fn for name, fn of require('./manipulators.coffee')

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
      files = replaceWildcards files
      for file in files
        compileFile = (curr, prev) ->
          # return if curr.mtime.getTime() is prev.mtime.getTime()
          console.log "Found change in #{@}, compiling #{packageName + '.' + extension}"
          compilePackage packageName + '.' + extension, files, dir, splitAssetGroup(keys).manipulators
        fs.watchFile file, _.bind compileFile, file
          
        
# Given an asset group split up it's packages and manipulators
splitAssetGroup = (group) ->
  packages = _.clone group
  manipulators =
    pre: group.preManipulate
    post: group.postManipulate  
  delete packages['preManipulate']
  delete packages['postManipulate']
  packages: packages, manipulators: manipulators

# Given a list of file strings, replaces the wild cards with the appropriate matches
replaceWildcards = (files) ->
  for fileIndex, file of files
    files.splice(fileIndex, 1, sentry.findWildcards(file)...) if sentry.findWildcards(file).length > 0
  
  _.uniq files
  
# Given a package name and list of file names concatenate the files and run the given
# manipulators in the order provided. Then output the concatenated package to the given directory.
compilePackage = (name, files, dir, manipulators) ->
  
  env = process.env.NODE_ENV || 'development'
  
  files = replaceWildcards files

  # Map files contents
  fileStrs = (fs.readFileSync(file).toString() for file in files)

  # Run any pre manipulators on each of the files
  for i, file of files
    if manipulators? and manipulators.pre? and (manipulators.pre[env]? or manipulators.pre['*']?)
      for manipulator in (manipulators.pre[env] ? manipulators.pre['*'])
        fileStrs[i] = manipulator(fileStrs[i], file)

  # Concatenate the files
  concatFileStr = (file for file in fileStrs).join '\n'

  # Run any post manipulators on the concatenated file
  if manipulators? and manipulators.post? and (manipulators.post[env]? or manipulators.post['*']?)
    for manipulator in (manipulators.post[env] ? manipulators.post['*'])
      concatFileStr = manipulator(concatFileStr)

  fs.writeFileSync "#{dir}/#{name}", concatFileStr