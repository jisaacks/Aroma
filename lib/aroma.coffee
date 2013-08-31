#! /usr/bin/env coffee

fs       = require "fs"
plist    = require "plist"
path     = require "path"
nconf    = require "nconf"

class Aroma
  constructor: ->
    # Check that we have something to compile
    if @_compile = nconf.get("compile")
      
      # Check for an output path
      @_output = nconf.get("output")
      
      # Are we to start watching for changes?
      @watch() if @_watch = nconf.get("watch")
      
      # If we are watching or not, compile now
      @compile()
    
    else
      @error "--compile is required"

  #-------

  error: (msg) ->
    # Write the message to standard error
    console.log msg
    process.stderr.write msg

  #-------

  log: (msg) ->
    # Write the message to standard out
    process.stdout.write msg

  #-------

  watch: ->
    @log "Watching #{@_compile}\n"
    
    # Watch the file/dir
    fs.watchFile @_compile, (curr,prev) =>
      
      # Check for changes
      if +curr.mtime != +prev.mtime
        
        # Compile
        @log "Change detected. Recompiling..."
        @compile()
        @log "Done.\n"

  build: (filepath) ->
    # Resolve the filepath
    filepath = path.resolve filepath
    
    # Delete the cache
    delete require.cache[filepath]
    
    # Import the aroma.coffee file
    scheme = require filepath
    
    # Compile to plist
    plist.build(scheme)

  #-------

  compile: ->
    # Check if @_compile is directory
    if fs.lstatSync(@_compile).isDirectory()

      # Compile all .aroma.coffee files in directory
      @compileDir @_compile
    else
      # Compile the file
      @compileFile @_compile

  #-------

  compileDir: (dirpath) ->
    # Iterate over all the files in dir
    for fname in fs.readdirSync dirpath
      
      # Check if file is an aroma coffee file
      if fname.substr(-13) == ".aroma.coffee"
        
        # Construct path to file
        filepath = "#{dirpath}/#{fname}"
        
        # Compile the file
        @compileFile filepath

  #-------

  compileFile: (filepath) ->
    # Grab the file name (minus ext) from the path
    filename = path.basename filepath, ".aroma.coffee"
    
    # Write to output or same dir as file
    outdir = @_output || path.dirname filepath
    
    # Determine the full file path we are writing to
    outfile = "#{outdir}/#{filename}.tmTheme"
    
    # Compile the .aroma.coffee file into plist format
    contents = @build filepath
    
    # Write the compiled contents to the outfile
    fs.writeFile outfile, contents, (err) ->
      @error err if err

# Get the whole thing started
nconf.env().argv()
new Aroma()

