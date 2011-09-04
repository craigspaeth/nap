# Module dependencies
fileUtil = require 'file'
_ = require 'underscore'
fs = require 'fs'

# Library of manipulator functions
@compileCoffeescript = (file) -> require('coffee-script').compile(file)

# Given an well formatted assets object, package will concatenate the files and 
# run manipulators in the order provided. Then output the concatenated package
# to the given directory.
@package = (assets, dir, options = { env: process.env.NODE_ENV || 'development' }) ->

  for extension, keys of assets
    
    # Split off the manipulators and packages
    packages = _.clone(keys)
    delete packages['preManipulate']
    delete packages['postManipulate'] 
    preManipulators = keys.preManipulate
    postManipulators = keys.postManipulate
    
    # Go through each package and concatenate the file contents into one file
    for packageName, files of packages
      
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
      
      # Convert the files array into strings of their contents
      files = (fs.readFileSync(file).toString() for file in files)
      
      # Run any pre manipulators on each of the files
      for i, file of files
        if preManipulators? and preManipulators[options.env]?
          for manipulator in preManipulators[options.env]
            files[i] = manipulator(file)
      
      # Concatenate the files
      concatFileStr = (file for file in files).join '\n'
      
      # Run any post manipulators on the concatenated file
      if postManipulators? and postManipulators[options.env]?
        for manipulator in postManipulators[options.env]
          concatFileStr = manipulator(concatFileStr)
      
      fs.writeFileSync "#{dir}/#{packageName}.#{extension}", concatFileStr