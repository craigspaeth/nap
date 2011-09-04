# Module dependencies
file = require 'file'
_ = require 'underscore'
fs = require 'fs'

# Given an well formatted assets object, package will concat the files and 
# run manipulators in the order provided. Then output the concatenated package
# to the given directory.
@package = (assets, dir, options = { env: process.env.NODE_ENV || 'development' }) ->

  for extension, keys of assets
    
    # Split off the manipulators and packages
    packages = _.clone(keys); delete packages['manipulators']
    manipulators = keys.manipulators
    
    # Go through each package and concatenate the file contents into one file
    for packageName, files of packages
      concatFileStr = (fs.readFileSync(file).toString() for file in files).join '\n'
      
      # Run the concatenated files through each manipulator in order
      if manipulators? and manipulators[options.env]?
        for manipulator in manipulators[options.env]
          concatFileStr = manipulator(concatFileStr)
      
      fs.writeFileSync "#{dir}/#{packageName}.#{extension}", concatFileStr