* Should Have
  * Font embedding
  * IE compatible packages
  * Only compiles files that have been touched since last compilation in dev mode
  * Real glob using https://github.com/isaacs/node-glob
  
* Could Have
  * Automatically strips out embedded images & fonts and puts them into a css file thats appended to the package to avoid accidentally bloating up a css package
  * nap.package() could be faster, should be asynchronously doing each package
  * Ability to be used as middleware