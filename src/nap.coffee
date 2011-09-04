# Module dependencies
file = require 'file'
_ = require 'underscore'
fs = require 'fs'

# Given an well formatted assets object, package will concat the files and 
# run manipulators in the order provided. Then output the concatenated package
# to the given directory.
@package = (assets, dir) ->

  for extension, keys of assets
    
    # Split off the manipulators and packages
    packages = _.clone(keys); delete packages['manipulators']
    manipulators = keys.manipulators
    
    # Go through each package and concatenate the file contents into one file
    for packageName, files of packages
      concatFileStr = (fs.readFileSync(file).toString() for file in files).join '\n'
      fs.writeFileSync "#{dir}/#{packageName}.#{extension}", concatFileStr