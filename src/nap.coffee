fileUtil = require 'file'
_ = require 'underscore'
fs = require 'fs'
path = require 'path'
sentry = require 'sentry'
knox = require 'knox'

# Attach manipulators to nap module
@[name] = fn for name, fn of require(__dirname + '/manipulators')

# Given a well formatted assets object, package will concatenate the files and 
# run manipulators in the order provided. Then output the concatenated package
# to the given directory.
@package = (assets, dir, options) ->
  packages = []
  for extension, keys of assets
    for packageName, files of splitAssetGroup(keys).packages
      packages.push(compilePackage(
        packageName + '.' + extension,
        replaceWildcards(files),
        dir,
        splitAssetGroup(keys).manipulators,
        if options then options.env else null
      ))
  packages
  
# Given a well formatted assets object, package will watch for any file changes in the
# one of the packages and re-compile that package.
@watch = (assets, dir) ->
  
  # Put a watcher on every file. If that file changes, compile it's package
  for extension, keys of assets
    for packageName, files of splitAssetGroup(keys).packages
      for file in files
        sentry.watch file, (filename) ->
          console.log "Found change in package #{packageName + '.' + extension}, compiling"
          compilePackage(
            packageName + '.' + extension,
            replaceWildcards(files),
            dir,
            splitAssetGroup(keys).manipulators
          )

# Given a well formatted assets object and S3 key, secret, bucket, and dir packageToS3 will run package
# and push the packages to the given dir in the S3 bucket.
@packageToS3 = (assets, dir, S3Options, callback) =>
  packages = @package assets, dir, S3Options.env ? 'production'
  
  # Setup knox client
  client = knox.createClient
    key: S3Options.key
    secret: S3Options.secret
    bucket: S3Options.bucket
  
  # Setup callback function
  responses = []
  finishPackaging = _.after packages.length, (responses) -> 
    callback (response.client._httpMessage.url for response in responses)
  
  # Go through each package and put to S3, add up the responses and callback when finished,
  # throwing any errors along the way
  for package in packages
    to = S3Options.dir + '/' + path.basename(package)
    client.putFile package, to, (err, res) ->
      throw err if err
      responses.push res
      console.log "Put package #{package} in S3 bucket '#{S3Options.bucket}' " +
                  "found at #{res.client._httpMessage.url}\n"
      finishPackaging responses

# Given an asset group split up it's packages and manipulators
splitAssetGroup = (group) ->
  packages = _.clone group
  manipulators =
    pre: group.preManipulate
    post: group.postManipulate  
  delete packages['preManipulate']
  delete packages['postManipulate']
  packages: packages, manipulators: manipulators

# Given a list of file strings, replaces the wild cards with the appropriate matches
replaceWildcards = (files) ->
  files = (for file in files
    if file.indexOf('/*') isnt -1 then sentry.findWildcards file else file)
  _.uniq _.flatten files
  
# Given a package name and list of file names concatenate the files and run the given
# manipulators in the order provided. Then output the concatenated package to the given directory.
compilePackage = (name, files, dir, manipulators, env) ->

  env = env ? process.env.NODE_ENV ? 'development'

  # Map files contents
  fileStrs = (fs.readFileSync(file).toString() for file in files)

  # Run any pre manipulators on each of the files
  for i, file of files
    if manipulators? and manipulators.pre? and (manipulators.pre[env]? or manipulators.pre['*']?)
      for manipulator in (manipulators.pre[env] ? manipulators.pre['*'])
        fileStrs[i] = manipulator(fileStrs[i], file)

  # Concatenate the files
  concatFileStr = (file for file in fileStrs).join '\n'

  # Run any post manipulators on the concatenated file
  if manipulators? and manipulators.post? and (manipulators.post[env]? or manipulators.post['*']?)
    for manipulator in (manipulators.post[env] ? manipulators.post['*'])
      concatFileStr = manipulator(concatFileStr)
  
  # Finally write the package to the directory
  fs.writeFileSync "./#{dir}/#{name}", concatFileStr
  
  "#{dir}/#{name}"