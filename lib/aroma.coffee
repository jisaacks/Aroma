#! /usr/bin/env coffee

fs       = require "fs"
plist    = require "plist"
path     = require "path"
nconf    = require "nconf"

build = (filepath) ->
  # Import the aroma.coffee file
  scheme = require(filepath)
  # Compile to plist
  plist.build(scheme)

compile = (filepath) ->
  # See if user specified output path
  output = nconf.get("output")
  # Grab the file name (minus ext) from the path
  filename = path.basename filepath, ".aroma.coffee"
  # Determine the directory we are writing to
  outdir = output || path.dirname filepath
  # Determine the full file path we are writing to
  outfile = "#{outdir}/#{filename}.tmTheme"
  # Compile the .aroma.coffee file into plist format
  contents = build path.resolve filepath
  # Write the compiled contents to the outfile
  fs.writeFile outfile, contents, (err) ->
    process.stderr.write err if err

nconf.env().argv()

if filepath = nconf.get("compile")
  compile filepath
else
  console.log "Nothing passed"

