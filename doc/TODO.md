* Gzipping
* Embed images manipulator
  # if not base64string or base64string.length > 32768
* Embed fonts manipulator
* Gracefully degrading packages using helpers to detect user-agents
* Examples folder
* Break out manipulators into their own file
* Default manipulators via file extension
* Extract file watching into a module (see below)


````coffeescript
# Node Module that acts a lot like watchr for ruby, it'll watch for any changes and run a task or execute a function

# Watch changes relative in file.js
watchr.watch 'file.js', (file, contents) -> console.log 'A change has been made in #{file}'

# Watch changes one directory deep
watchr.watch 'fld/*.coffee', ->

# Watch changes recursively on any files 
watchr.watch 'fld/**/*.coffee',->

# Watch files recursively that match a regex
watchr.watch /regex/, ->

# If you pass a string it'll execute that shell command
watchr.watch 'file.coffee', 'coffee -c'
````