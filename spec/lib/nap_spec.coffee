require '../helpers/spec_helper.coffee'
nap = require '../../src/nap.coffee'
fs = require 'fs'
_ = require 'underscore'
knox = require ('knox')

describe 'nap.package', ->
  
  runAsync()
  
  it 'outputs packages to the given directory', ->
    nap.package require('../stubs/assets_stub.coffee'), 'spec/fixtures/assets'
    expect(_.indexOf(fs.readdirSync('spec/fixtures/assets'), 'foo.js')).toNotEqual -1
    done()
  
  it 'outputs concatenated file contents to a package in the order provided', ->
    nap.package require('../stubs/assets_stub.coffee'), 'spec/fixtures/assets'
    expect(fs.readFileSync('spec/fixtures/assets/foo.js').toString()).toEqual "var foo = 'foo';\nvar bar = 'bar';"
    done()
    
  it 'outputs multiple packages', ->
    nap.package require('../stubs/assets_stub3.coffee'), 'spec/fixtures/assets'
    expect(fs.readFileSync('spec/fixtures/assets/foo.js').toString()).toEqual "var foo = 'foo';"
    expect(fs.readFileSync('spec/fixtures/assets/foo.css').toString()).toEqual ".foo { background: red; }"
    expect(fs.readFileSync('spec/fixtures/assets/bar.js').toString()).toEqual "var bar = 'bar';"
    done()
    
  it 'returns the file paths of the packages', ->
    package = nap.package require('../stubs/assets_stub3.coffee'), 'spec/fixtures/assets'
    assert = ['spec/fixtures/assets/foo.js', 'spec/fixtures/assets/bar.js', 'spec/fixtures/assets/foo.css']
    equal = _.isEqual package, assert
    expect(equal).toBeTruthy()
    done()
    
  it 'can be passed a env in options to emulate an environemnt', ->
    nap.package require('../stubs/assets_stub2.coffee'), 'spec/fixtures/assets',
      env: 'production'
    expect(fs.readFileSync('spec/fixtures/assets/foo.js').toString()).toEqual "var foo = 'foo';bar\nvar bar = 'bar';bar"
    done()
  
  describe 'using wild cards', ->
  
    runAsync()
    
    it 'takes wildcards in the /path/to/**/* form and splices them in place', ->
      nap.package require('../stubs/assets_stub4.coffee'), 'spec/fixtures/assets'
      expect(fs.readFileSync('spec/fixtures/assets/foo.js').toString()).toEqual(
        "var foo = 'foo';\nbar2 = 'bar2'\nvar foo1 = 'foo1';\nvar foo2 = 'foo2';\nvar foo3 = 'foo3';\nvar bar = 'bar';"
      )
      done()
    
    it 'takes wildcards in the /path/to/**/*.js form and splices them in place, excluding the wrong extension', ->
      nap.package require('../stubs/assets_stub5.coffee'), 'spec/fixtures/assets'
      expect(fs.readFileSync('spec/fixtures/assets/foo.js').toString()).toEqual(
        "var foo = 'foo';\nvar foo1 = 'foo1';\nvar foo2 = 'foo2';\nvar foo3 = 'foo3';\nvar bar = 'bar';"
      )
      done()
    
    it 'takes wildcards in the /* form and splices them in place, going only one directory deep', ->
      nap.package require('../stubs/assets_stub6.coffee'), 'spec/fixtures/assets'
      expect(fs.readFileSync('spec/fixtures/assets/foo.js').toString()).toEqual(
        "var foo = 'foo';\nbar2 = 'bar2'\nvar foo1 = 'foo1';\nvar bar = 'bar';"
      )
      done()
    
    it 'takes wildcards in the /*.js form and splices them in place, going only one directory deep,
        and excluding the wrong extension', ->
      nap.package require('../stubs/assets_stub7.coffee'), 'spec/fixtures/assets'
      expect(fs.readFileSync('spec/fixtures/assets/foo.js').toString()).toEqual(
        "var foo = 'foo';\nvar foo1 = 'foo1';\nvar bar = 'bar';"
      )
      done()
      
    it 'doesnt add files already specified', ->
      nap.package require('../stubs/assets_stub1.coffee'), 'spec/fixtures/assets'
      expect(fs.readFileSync('spec/fixtures/assets/foo.css').toString()).toEqual(
        ".foo { background: red; }"
      )
      done()
    
    it 'replaces all wildcards', ->
      nap.package require('../stubs/assets_stub13.coffee'), 'spec/fixtures/assets'
      expect(fs.readFileSync('spec/fixtures/assets/backbone.js').toString()).toEqual(
        "d\na\nb\nf\ne"
      )
      done()
      
  describe 'given a preManipulate', ->
  
    runAsync()
    
    it 'runs the preManipulate function on the files', ->
      process.env.NODE_ENV = 'development'
      nap.package require('../stubs/assets_stub2.coffee'), 'spec/fixtures/assets'
      expect(fs.readFileSync('spec/fixtures/assets/foo.js').toString()).toEqual "var foo = 'foo';foo\nvar bar = 'bar';foo"
      done()
      
    it 'runs the manipulator function on the concatenated files depending on node env', ->
      process.env.NODE_ENV = 'production'
      nap.package require('../stubs/assets_stub2.coffee'), 'spec/fixtures/assets'
      expect(fs.readFileSync('spec/fixtures/assets/foo.js').toString()).toEqual "var foo = 'foo';bar\nvar bar = 'bar';bar"
      done()
      
    it 'runs the manipulator function on the concatenated files regardless of env if provided a wildcard', ->
      process.env.NODE_ENV = 'foo'
      nap.package require('../stubs/assets_stub10.coffee'), 'spec/fixtures/assets'
      expect(fs.readFileSync('spec/fixtures/assets/foo.js').toString()).toEqual "var foo = 'foo';foo\nvar bar = 'bar';foo"
      done()
      
  describe 'given a postManipulate', ->
  
    runAsync()
    
    it 'runs the postManipulate function on the files', ->
      process.env.NODE_ENV = 'development'
      nap.package require('../stubs/assets_stub8.coffee'), 'spec/fixtures/assets'
      expect(fs.readFileSync('spec/fixtures/assets/foo.js').toString()).toEqual "var foo = 'foo';\nvar bar = 'bar';baz"
      done()
      
    it 'runs the manipulator function on the concatenated files depending on node env', ->
      process.env.NODE_ENV = 'production'
      nap.package require('../stubs/assets_stub8.coffee'), 'spec/fixtures/assets'
      expect(fs.readFileSync('spec/fixtures/assets/foo.js').toString()).toEqual "var foo = 'foo';\nvar bar = 'bar';qux"
      done()
      
describe 'nap.watch', ->
  
  runAsync()
  
  it 'regenerates a package when a file is changed', ->
    file = 'spec/fixtures/watch_js/foo.js'
    fs.writeFile 'spec/fixtures/assets/watch.js', ''
    fs.writeFileSync file, 'var foo = \'foo\''
    nap.watch require('../stubs/assets_stub9.coffee'), 'spec/fixtures/assets'
    fs.writeFileSync file, "Hello World"
    fs.watchFile file, (curr, prev) ->
      expect(fs.readFileSync('spec/fixtures/assets/watch.js').toString()).toEqual "Hello World"
      fs.unwatchFile file
      done()
      
  it 'watches for files caught by wildcards too', ->
    file = 'spec/fixtures/watch_js/foo.js'
    fs.writeFile 'spec/fixtures/assets/watch.js', ''
    fs.writeFileSync file, 'var foo = \'foo\''
    nap.watch require('../stubs/assets_stub12.coffee'), 'spec/fixtures/assets'
    fs.writeFileSync file, "Hello Mars"
    fs.watchFile file, (curr, prev) ->
      expect(fs.readFileSync('spec/fixtures/assets/watch.js').toString()).toEqual "Hello Mars"
      done()

s3Opts = JSON.parse(fs.readFileSync(__rootdir + '/.s3auth').toString())
s3Opts.dir = '/assets'
knoxClient = knox.createClient
  key: s3Opts.key
  secret: s3Opts.secret
  bucket: s3Opts.bucket

describe 'nap.packageToS3', ->
  
  runAsync()
  
  it 'sends a package to S3 given the proper options', ->
    nap.packageToS3 require('../stubs/assets_stub11.coffee'), 'spec/fixtures/assets', s3Opts, ->
      knoxClient.getFile '/assets/bar.js', (err, res) ->
        res.on 'data', (chunk) ->
          expect(chunk.toString()).toEqual "var foo = 'foo';\nvar bar = 'bar';"
          done()
      
  xit 'callsback with an array of package urls from the packages', ->
    nap.packageToS3 require('../stubs/assets_stub.coffee'), 'spec/fixtures/assets', s3Opts, (packages) ->
      expect(packages[0].match /^http.*foo\.js$/).toBeTruthy()
      done()