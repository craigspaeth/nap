var express = require('express');
var routes = require('./routes');
var http = require('http');
var path = require('path');
var nap = require(process.cwd() + '../../lib');
var app = express();

// nap config
nap({
  assets: {
    js: {
      alerts: [
        '/scripts/one.js',
        '/scripts/two.js',
        '/scripts/**/**.coffee'
      ]
    },
    css: {
      all: [
        '/stylesheets/**/*'
      ]
    },
    jst: {
      templates: [
        '/templates/**/*.jade'
      ]
    }
  }
});
app.locals.nap = nap;

// express config
app.configure(function(){
  app.set('port', process.env.PORT || 4000);
  app.set('views', __dirname + '/views');
  app.set('view engine', 'jade');
  app.use(express.favicon());
  app.use(express.logger('dev'));
  app.use(express.bodyParser());
  app.use(express.methodOverride());
  app.use(app.router);
  app.use(express.static(path.join(__dirname, 'public')));
});
app.configure('development', function(){
  app.use(express.errorHandler());
});

// routes
app.get('/', routes.index);

// Package assets & start server
nap.package(function() {
  http.createServer(app).listen(app.get('port'), function(){
    console.log("Express server listening on port " + app.get('port'));
  });
});