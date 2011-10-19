# Node Asset Packager

Compiling, packaging, minifying, and compressing your client side assets got you all strung out? Relax, take a nap.

(nap) Node Asset Packager is a module inspired by [Jammit](http://documentcloud.github.com/jammit/) and [Connect Asset Manager](https://github.com/mape/connect-assetmanager) that helps compile and package your assets including stylesheets, javascripts, and javascript templates.

## Installation

    $ npm install nap

## Example

````coffeescript
nap = require 'nap'

assets = 
  
  js:

    preManipulate:
      '*': [nap.compileCoffeescript]
    postManipulate: 
      'production': [nap.uglifyJS]

    backbone: [
      'app/coffeescripts/models/**/*.coffee'
      'app/coffeescripts/views/**/*.coffee'
      'app/coffeescripts/routers/**/*.coffee'
    ]

  css:

    preManipulate:
      '*': [nap.compileStylus]
    postManipulate: 
      'production': [nap.yuiCssMin]

    all: [
      'public/stylesheets/blueprint.css'
      'app/stylesheets/**/*.styl'
    ]

  jst:
  
    preManipulate:
      '*': [nap.packageJST]
    postManipulate: 
      '*': [nap.prependJST("require('jade').compile")]

    templates: [
      'app/templates/index.jade'
      'app/templates/footer.jade'
    ]

switch process.env.NODE_ENV
  when 'production' then nap.package assets, 'public/assets'
  when 'development'then nap.watch assets, 'public/assets'
````

Then simply reference your packages in your layout

````html
<script type='text/javascript' src='assets/backbone.js'>
<script type='text/javascript' src='assets/templates.jst'>
<link rel="stylesheet" type="text/css" href="assets/all.css" />
````

This example...

* Compiles coffeescripts in various folders, merges & minifies the outputted js with uglifyJS in _production_
* Compiles stylus in `app/stylesheets` dir, merges blueprint.css with the compiled stylus, and finally minifies the result with YUI in _production_.
* Packages two jade templates similar to how Jammit does, using the jade client side compiler function when called (See _manipulators_ below).
* Outputs backbone.js, all.css, and template.jst package files to `public/assets` once in _production_
* Watches for any file changes in any of the packages, and recompiles that package in _development_ 
    
## Explaining nap

nap provides a library to manipulate, package, and finally output your client side assets in to a directory of your project. Give nap a well formatted asset object describing the packages and nap will output them into a directory of your choice.

There are currently two functions that take a nap asset object.

````coffeescript
# Runs the magic once and outputs the given assets to public/assets
nap.package assets, 'public/assets'

# Watches for file changes on a specific file and only re-compiles that package
nap.watch assets, 'output/path/of/choice'

# Packages files to public/assets and then pushes to to the 'gassets' folder in the 'my-bucket'' S3 bucket
nap.watch assets, 'public/assets',
  key: "KEY"
  secret: "SECRET"
  bucket: "my-bucket"
  dir: "assets"
````

## Examples of nap asset objects

_Package & minify vendor javascripts_

````coffeescript
assets =

  js:
    postManipulate: 
      '*': [nap.uglifyJS]

    vendor: ['public/javascripts/vendor/**/*.js']    
````
    
_Compile & package a bunch of coffeescripts. Minify only in production_

````coffeescript
assets =

  js:
    preManipulate:
      '*': [nap.compileCoffeescript]
    postManipulate: 
      'production': [nap.uglifyJS]

    mvc: [
      'app/coffeescripts/models/**/*.coffee'
      'app/coffeescripts/views/**/*.coffee'
      'app/coffeescripts/controllers/**/*.coffee'
    ]
````      

_Compile stylus into a CSS package_

````coffeescript
assets =

  css:
    preManipulate:
      '*': [nap.compileStylus]
    postManipulate: 
      'production': [nap.yuiCssMin]

    plugins: [
      'app/stylus/plugins/**/*.styl'
      'app/stylus/plugins/**/*.styl'
    ]
````

_Compile javascript templates using Jade's client side compiler function_

````coffeescript
assets =

  jst:
    preManipulate:
      '*': [nap.packageJST]
    postManipulate: 
      '*': [nap.prependJST("require('jade').compile")]

    plugins: [
      'app/templates/index.jade'
      'app/templates/footer.jade'
    ]
````

## Explaining the asset object

The assets object consists of a couple layers. First level is the package extensions. (_.js_, _.css_, and _.jst_) These simply determine the package file extensions and groups packages and manipulators together. Inside an extension you can specify keys `preManipulate`, `postManipulate`, and from then on each key describes a package.

## Packages

Packages are any key inside an extension not labeled `preManipulate` or `postManipulate`. _(Don't name a package preManipulate.css)_ 

Packages are simply an array of file path strings. You may also pass wild cards in the form of `**/*` to recursively add all files in that directory or `/*` for just all files one level deep in that directory.
  
````coffeescript
# Recursively add all files in the folder app/javascripts/vendor/ to be ouput to vendor.js
assets =
  
  js:
    
    vendor: ['app/javascripts/vendor/**/*.js']
````

## Manipulators

`preManipulate` and `postManipulate` are first specified by a key to determine the environment you wish to run the resulting functions on.

````coffeescript
# Wildcard for any environment
preManipulate:
  '*': [nap.compileCoffeescript]
  
# Otherwise just name the environment
postManipulate:
  'production': [nap.uglifyJS]
postManipulate:
  'test': ...
````

Give an environment key an array of functions, and nap will run them in order on the files to be packaged. `preManipulate` is passed `(contents, filename)` and is run on each individual file in a package before being merged. `postManipulate` is passed `(contents)` and is run after each file in a package has been merged.  
    
````coffeescript
# Compiles any coffeescript files with the .coffee extension, prepends a comment denoting it being a compiled file, 
# concatenates all of the files into one, then runs uglifyJS on the merged files.
assets =

  js:
    preManipulate:
      '*': [
        ((contents, filename) ->
          if filename? and filename.match(/.coffee$/)?
            return require('coffee-script').compile contents
          else
            return contents
        ),
        ((contents, filename)) ->
          if filename? and filename.match(/.coffee$/)?
            return "// This file was a compiled coffeescript file.\n" + contents
          else
            return contents
        )
      ]
    
    postManipulate: 
      '*': [nap.uglifyJS]

    mvc: [
      'app/coffeescripts/models/**/*.coffee'
      'app/coffeescripts/views/**/*.coffee'
      'app/coffeescripts/controllers/**/*.coffee'
    ]
````

## nap Manipulators

Although you can pass any custom manipulator function, nap provides a handful of common manipulator functions. Simply require nap `nap = require('nap')` and pass any of the following namespaced functions.

### Pre-manipulators

    nap.compileCoffeescript

Runs the coffeescript compiler on files with the .coffee extension

    nap.compileStylus

Runs the stylus compiler on any of files with the .styl extension

    nap.packageJST

Packages the contents of the files into `window.JST['file/path']` namespaces. The path is determined by the folder path where the file resides _(beginning from a templates folder if provided)_ with the extension removed. 

e.g. A file in `app/templates/home/index.jade` will be packaged as `window.JST['home/index'] = JSTCompile('h1 Hello World');`
    
### Post-manipulators

    nap.uglifyJS

Runs uglifyJS on the merged files

    nap.yuiCssMin  
    
Runs the YUI css compressor on the merged files

    nap.embedImages('public')

Embeds any images using data-uri. You must specify the local directory the images are located in. In this example a style such as `.foo { background: url('/images/bar.png') }` would be pointing to a file in `public/images`

    nap.prependJST('Haml')
    
Used in conjunction with nap.packageJST to determine what client-side javascript template compiler function you want to use. Pass the function name as a string. e.g. `nap.prependJST('Haml')` or `nap.prependJST('Mustache.to_html')`
      
## To run tests

You must first have a test S3 bucket and create a `.s3auth` file in the root directory and add s3 credentials in JSON format like so:

    {"key":"foo",
     "secret":"bar",
     "bucket":"baz"}
     
This is to test nap's packageToS3 function.

nap uses [Jasmine-node](https://github.com/mhevery/jasmine-node) for testing. Simply run the jasmine-node command with the coffeescript flag

    jasmine-node spec --coffee