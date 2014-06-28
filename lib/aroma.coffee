#! /usr/bin/env coffee

fs       = require "fs"
plist    = require "plist"
path     = require "path"
optimist = require "optimist"

# Setup optimist options
argv = optimist
  
  # Define aliases
  .alias(c:"compile", o:"output", w:"watch", e:"extension")
  
  # Set the defaults
  .default(c:".", e:"plist")
  
  # Specify --watch as boolean flag
  .boolean("w")
  
  # Require --compile to be a string
  .check((args)-> typeof args.c == "string")

  # Return the the argument object
  .argv

class Aroma
  constructor: ->
    # What are we compiling?
    @_compile = argv.compile
      
    # Check for an output path
    @_output = argv.output
    
    # Are we to start watching for changes?
    @watch() if argv.watch
    
    # If we are watching or not, compile now
    @compile()

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
    outfile = "#{outdir}/#{filename}.#{argv.extension}"
    
    # Compile the .aroma.coffee file into plist format
    contents = @build filepath
    
    # Write the compiled contents to the outfile
    fs.writeFile outfile, contents, (err) =>
      @error err if err

# Get the whole thing started
new Aroma()

