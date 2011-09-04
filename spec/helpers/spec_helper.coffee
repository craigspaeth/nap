# Run an entire suite aynchronously
_done = false
@done = -> _done = true
@runAsync = ->
  beforeEach -> _done = false
  afterEach -> waitsFor -> _done