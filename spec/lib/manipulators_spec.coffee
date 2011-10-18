require '../helpers/spec_helper.coffee'
fs = require 'fs'
nap = require '../../src/nap.coffee'
_ = require 'underscore'
path = require 'path'

# Local fixtures
assets1 = 
  js:
    preManipulate:
      'development': [nap.compileCoffeescript]
  
    foo: [
      'spec/fixtures/coffeescripts/**/*.coffee'
    ]
    
  css:
    preManipulate:
      'development': [nap.compileStylus]
  
    foo: [
      'spec/fixtures/stylus/**/*.styl'
    ]
    
  'import.css':
    preManipulate:
      'development': [nap.compileStylus]
  
    foo: [
      'spec/fixtures/stylus_import/foo.styl'
    ]
    
  'nib.css':
    preManipulate:
      'development': [nap.compileStylus]
  
    foo: [
      'spec/fixtures/nib/foo.styl'
    ]

describe 'nap.compileCoffeescript', ->

  runAsync()

  it 'compiles coffeescript to js', ->
    expect(nap.compileCoffeescript("foo = 'bar'", 'foo.coffee').indexOf("var foo") isnt -1).toBeTruthy()
    done()
    
  it 'doesnt try to compile js', ->
    expect(nap.compileCoffeescript("var foo = 'bar';", 'foo.js')).toEqual "var foo = 'bar';"
    done()
    
  it 'when run through package compiles coffeescript files to js', ->
    process.env.NODE_ENV = 'development'
    nap.package assets1, 'spec/fixtures/assets'
    contents = fs.readFileSync('spec/fixtures/assets/foo.js').toString()
    expect(contents.indexOf("foo = 'foo';\n}).call(this);") isnt -1).toBeTruthy()
    expect(contents.indexOf("foo1 = 'foo1';\n}).call(this);") isnt -1).toBeTruthy()
    done()
    
describe 'nap.compileStylus', ->
  
  runAsync()
  
  it 'compiles stylus to css', ->
    expect(nap.compileStylus("foo\n  background red", 'foo.styl').indexOf('background: #f00;') isnt -1).toBeTruthy()
    done()
    
  it 'doesnt try to compile non stylus', ->
    expect(nap.compileStylus(".foo { background red; }", 'foo.css')).toEqual ".foo { background red; }"
    done()
  
  it 'when run through package compiles stylus files to css', ->
    process.env.NODE_ENV = 'development'
    nap.package assets1, 'spec/fixtures/assets'
    contents = fs.readFileSync('spec/fixtures/assets/foo.css').toString()
    expect(contents.indexOf("background: #f00;") isnt -1).toBeTruthy()
    expect(contents.indexOf("background: #00f;") isnt -1).toBeTruthy()
    done()
    
  it 'can handle imports correctly', ->
    nap.package assets1, 'spec/fixtures/assets'
    contents = fs.readFileSync('spec/fixtures/assets/foo.import.css').toString()
    expect(contents.indexOf("background: #f00;") isnt -1).toBeTruthy()
    expect(contents.indexOf("color: #00f;") isnt -1).toBeTruthy()
    done()
    
  it 'comes with nib', ->
    nap.package assets1, 'spec/fixtures/assets'
    contents = fs.readFileSync('spec/fixtures/assets/foo.nib.css').toString()
    expect(contents.indexOf("display: -webkit-box;") isnt -1).toBeTruthy()
    done()
    
describe 'nap.packageJST', ->
  
  runAsync()
  
  it 'packs files into JST[path/to/file] = JSTCompile(fileContents)', ->
    str = 'window.JST["path/to/index"] = JSTCompile("h1 Hello World");'
    expect(nap.packageJST('h1 Hello World', 'path/to/index.jade').indexOf str).toNotEqual -1
    done()
    
  it 'packs templates in relative dirs to the templates folder', ->
    expect(nap.packageJST('h1 Hello World', 'path/to/templates/foo/index.jade').indexOf(
      'window.JST["foo/index"] = JSTCompile("h1 Hello World");'
    )).toNotEqual -1
    done()

  it "escapes newline characters", ->
    str = "h1 Hello World\nh2 Can I haz cheezeburger?\n"
    expect(nap.packageJST(str, 'path/to/templates/foo/index.jade').indexOf(
      'window.JST["foo/index"] = JSTCompile(\"h1 Hello World\\nh2 Can I haz cheezeburger?\\n\");'
    )).toNotEqual -1
    done()

  it "escapes double quotes characters", ->
    str = 'h1 "Hello World"'
    expect(nap.packageJST(str, 'path/to/templates/foo/index.jade').indexOf(
      'window.JST["foo/index"] = JSTCompile(\"h1 \\\"Hello World\\\"\");'
    )).toNotEqual -1
    done()
    
describe 'nap.prependJST', ->

  runAsync()
  
  it 'returns a function that prepends a JST object and the provided Compile function', ->
    expect(nap.prependJST('Jade')('foo').indexOf 'window.JST = {}').toNotEqual -1
    expect(nap.prependJST('Jade')('foo').indexOf 'window.JSTCompile = Jade').toNotEqual -1
    done()
  
  xit 'prepends a window JST object', ->
    expect(nap.prependJST('h1 Hello World', 'path/to/index.jade').indexOf 'window.JST = {}').toNotEqual -1
    done()
    
  xit 'inserts an empty JSTCompile function', ->
    str = "if(typeof window.JSTCompile !== 'function') { throw new Error('You must provide a JSTCompile function.') };"
    expect(nap.prependJST('h1 Hello World', 'path/to/index.jade').indexOf str).toNotEqual -1
    done()
    
describe 'nap.ugilfyJS', ->
  
  runAsync()
  
  it 'compresses js using UgilfyJS', ->
    expect(nap.ugilfyJS('foo["bar"]')).toEqual('foo.bar')
    done()
    
describe 'nap.yuiCssMin', ->
  
  runAsync()
  
  it 'compresses css using YUI compressor', ->
    expect(nap.yuiCssMin('body {   \n\n background: red;\n\n   }')).toEqual 'body{background:red}'
    done()
    
describe 'nap.embedImages', ->
  
  runAsync()
  
  it 'turns any url() to be replaced with the base 64 encoding of the local file if it exists', ->
    newCss = nap.embedImages(path.join(__dirname, '..', '/fixtures'))('.foo { background: url(/images/img.png)}')
    expect(newCss.indexOf("url(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAIAAAACCAIAAAD91J")).toNotEqual -1
    done()
    
  it 'doesnt change the url() paths if the local file doesnt exist', ->
    newCss = nap.embedImages(path.join(__dirname, '..', '/fixtures'))('.foo { background: url(/images/img_gone.png)}')
    expect(newCss.indexOf("url(/images/img_gone.png")).toNotEqual -1
    done()
    
  it 'handles multiple url()s like a champ', ->
    css = '.foo { background: url(/images/img.png) } .bar { background: url(/images/img2.png) }'
    newCss = nap.embedImages(path.join(__dirname, '..', '/fixtures'))(css)
    expect(newCss.indexOf("url(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAIAAAACCAIAAAD91J")).toNotEqual -1
    expect(newCss.indexOf("url(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAADCAIAAADdv/")).toNotEqual -1
    done()
    
  it 'handles images with quotes in the url like a champ', ->
    css = '.foo { background: url("/images/img.png") } .bar { background: url(\'/images/img2.png\') }'
    newCss = nap.embedImages(path.join(__dirname, '..', '/fixtures'))(css)
    expect(newCss.indexOf("url(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAIAAAACCAIAAAD91J")).toNotEqual -1
    expect(newCss.indexOf("url(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAADCAIAAADdv/")).toNotEqual -1
    done()
