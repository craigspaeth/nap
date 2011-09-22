* Embed images manipulator
  # if not base64string or base64string.length > 32768
* Embed fonts manipulator
* Gzipping
* nap.easyMode = true for default manipulators (e.g. All compilers are default. Ugilfy, yuiCSS, and JST packaging are done on .js, .css, and .jst)
* Gracefully degrading packages using helpers to detect user-agents
* Examples folder
* Find sainer way to do JSTs (Compile jade into javascript strings, prepend a JST object so JST['foo/bar'] from a templates folder

* Error for callback from packageToS3
/Users/Craig/inertia/node_modules/nap/lib/nap.js:73
          _results.push(response.client._httpMessage.url);
                                                    ^
TypeError: Cannot read property 'url' of null
    at /Users/Craig/inertia/node_modules/nap/lib/nap.js:73:53
    at /Users/Craig/inertia/node_modules/nap/lib/nap.js:76:8
    at /Users/Craig/inertia/node_modules/underscore/underscore.js:537:38
    at /Users/Craig/inertia/node_modules/nap/lib/nap.js:88:16
    at ClientRequest.<anonymous> (/Users/Craig/inertia/node_modules/nap/node_modules/knox/lib/knox/client.js:160:7)
    at ClientRequest.emit (events.js:64:17)
    at HTTPParser.onIncoming (http.js:1336:9)
    at HTTPParser.onHeadersComplete (http.js:108:31)
    at Socket.ondata (http.js:1213:22)
    at Socket._onReadable (net.js:681:27)
    
* Watch is throwing the wrong filename & package

Found change in package templates.jst.js, compiling