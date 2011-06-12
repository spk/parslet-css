# Parslet CSS

Simple CSS parser with [Parslet](http://kschiess.github.com/parslet/)

Work in progress

## Usage

```ruby
require 'parslet-css'
parser = ParsletCSS::Parser.new
parser.parse("body { background: url(/images/plop.png); }") # => [{:url=>"/images/plop.png"@23}]
```

## License
The MIT License

Copyright © 2011 Laurent Arnoud <laurent@spkdev.net>
