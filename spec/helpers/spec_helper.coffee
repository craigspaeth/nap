path = require 'path'

# Run an entire suite aynchronously
_done = false
@done = -> _done = true
@runAsync = ->
  beforeEach -> _done = false
  afterEach -> waitsFor -> _done

# Store the nap module dir
global.__rootdir = path.resolve __dirname, '../../'