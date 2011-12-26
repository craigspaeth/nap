# Node Asset Packager

(nap) Node Asset Packager helps compile and package your assets including stylesheets, javascripts, and client-side javascript templates.

## Example

Declare asset packages

````coffeescript
global.nap = require('nap')

nap
  assets:
    js:
      backbone: [
        '/app/coffeescripts/models/**/*'
        '/app/coffeescripts/views/**/*'
        '/app/coffeescripts/routers/**/*'
      ]
    css:
      all: [
        '/public/stylesheets/blueprint.css'
        '/app/stylesheets/**/*'
      ]
    jst:
      templates: [
        '/app/templates/index.jade'
        '/app/templates/footer.jade'
      ]
````

Include packages in your views by calling one of nap's helpers

````jade
!!!
html
  head
    title= title
    != nap.css('all')
  body
    != body
    #scripts
      != nap.jst('templates')
      != nap.js('backbone')
````

Concatenate & minify once for production

````coffeescript
nap
  mode: 'production'
  assets:
    js: # ...
    css: # ...
    jst: # ...
  
nap.package()
````

Some express.js app based examples can be found in the [examples folder](https://github.com/craigspaeth/nap/tree/master/examples).

## API

To make things easy nap assumes you have a `/public` folder (like an Express.js or Ruby on Rails public folder) so that nap can generate & reference assets inside `/public/assets`.

### Packages

A package is an ordered set of directory glob rules that will be expanded into a list of files. Declare packages by name-spacing them inside the assets object of the nap constructor. 

````coffeescript
nap
  assets:
    js:
      backbone: [
        'app/scripts/vendor/backbone.js'
        'app/scripts/models/**/*'
        'app/scripts/collections/**/*'
        'app/scripts/views/**/*'
        'app/scripts/routers/**/*'
        'app/scripts/app.coffee'
      ]
    css:
      common: [
        'app/stylesheets/reset.styl'
        'app/stylesheets/widgets/*.css'
      ]
    jst:
      templates: [
        'app/templates/*.jade'
      ]
````

### JS & CSS Pre-processors

Nap will run any pre-processors on `js` and `css` packages based on the file extensions.

Nap only currently supports the following pre-processors. But please feel free to contribute more.
  
  * [Coffeescript](http://jashkenas.github.com/coffee-script/) (.coffee)
  * [Stylus](https://github.com/LearnBoost/stylus) (.styl)

### Client-side Javascript Templating (JSTs) 

`jst` packages will run the appropriate template engine parser based off the file extension. Nap will then namespace your client-side templates into a global `JST['file/path']` function, much like [Jammit](http://documentcloud.github.com/jammit/#jst). The namespace is the file directory following "templates" without the file extension.

e.g. The template `app/templates/artwork/detail.jade` will be parsed using jade and can be rendered on the client-side by calling `JST['artwork/detail']({ title: 'Mona Lisa' })`

Nap only currently supports the following templating engines. But please feel free to contribute more.

 * [Jade](https://github.com/visionmedia/jade) (.jade)

### Nap modes

Nap has two modes 'development' and 'production'.

**Development**

In development, nap will run any pre-processors and output a bunch of individual `<script>` and `<link>` tags using one of it's helpers (`nap.js(...), nap.css(...), nap.jst(...)`). Each time these helpers are called they will re-compile these files, resulting in seamless asset compilation on page refresh.

**Production**
  
In production use the `nap.package()` function once (e.g. upon deployment).

Calling nap.package() will concatenate all of the files in a package, minify, and finally output the result to a single package file (e.g. `public/assets/package-name.js`). 

Calling one of nap's helpers in production mode will simply return a `<script>` or `<link>` tag pointing to the generated package file.

### Options

* assets
  * the assets object containing all of your packages
* publicDir
  * your public directory, defaults to `/public`
* mode
  * the mode you want nap to be in 'production' or 'development', defaults to 'production' on NODE_ENV=staging and NODE_ENV=production, otherwise 'development'
* cdnUrl
  * If you are using a CDN you can pass the url root of where your assets are stored and nap will point there instead of locally in 'production' mode.
* embedImages
  * When true, it embeds image urls in CSS using data-uri (defaults to false)
* embedFonts
  * When true, it embeds font urls in CSS using data-uri (defaults to false)
* gzip
  * Gzips packages .jgz and .cgz asset packages. The helpers will point to these gzipped packages in production mode unless you pass false as a second argument (nap.js('package-name', false))  (defaults to false)

````coffeescript
nap
  publicDir: '/public'
  mode: if process.env.NODE_ENV is 'production' then 'production' else 'development'
  cdnUrl: 'http://s3.amazonaws.com/my-bucket/assets/'
  embedImages: true
  embedFonts: true
  gzip: true
  assets:
    js:
      backbone: [
        '/app/coffeescripts/models/**/*'
        '/app/coffeescripts/views/**/*'
        '/app/coffeescripts/routers/**/*'
      ]
    css:
      all: [
        '/public/stylesheets/blueprint.css'
        '/app/stylesheets/**/*'
      ]
    jst:
      templates: [
        '/app/templates/index.jade'
        '/app/templates/footer.jade'
      ]
````

## Installation

`npm install nap`

## Tests

Nap uses [Mocha](https://github.com/visionmedia/mocha) for testing. Simply run `mocha` to run the test suite.

## License

(The MIT License)

Copyright (c) Craig Spaeth <craigspaeth@gmail.com>, Art.sy, 2011

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the 'Software'), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.