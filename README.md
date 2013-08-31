## Aroma

Command line utility to compile [CoffeeScript](http://coffeescript.org/) objects into [property list](http://en.wikipedia.org/wiki/Property_list) files.

---

### Rationale

A plist file is very verbose and cumbersome to edit. Aroma lets you define your property lists in CoffeeScript with a much more terse syntax with the added benefit of using logic and variables.

Just create an .aroma.coffee file that exports the object you wish to use:

```coffeescript
foo = "Dynamic!"

module.exports =
  foo: foo
  baz: "bar"
```

The generated plist will be:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <key>foo</key>
    <string>Dynamic!</string>
    <key>baz</key>
    <string>bar</string>
  </dict>
</plist>
```

Notice how much more terse the coffee file is? Did you also notice how we used a variable!

---

### Usage

__Compile a single file:__

* `$ aroma -c myfile.aroma.coffee`

__Compile all the aroma coffee files in `./src` to plist files in `./lib`:__

* `$ aroma -o lib -c src`

__Watch the current directory for any changes and automatically compile .aroma.coffee files:__

* `$ aroma -w`

__Specify what extension to save the property list as:__

* `$ aroma -e ".tmTheme"`

---

### Installation

Aroma is a Node.js module so first you must install [Node.js](http://nodejs.org/) then run `npm install -g aroma`

---

### License

MIT