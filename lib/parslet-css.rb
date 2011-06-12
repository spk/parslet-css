# encoding: UTF-8
require 'parslet'

class ParsletCSS
  VERSION = "0.0.1"

  autoload :Parser, 'parslet-css/parser'

  def self.compile(str)
    parser = ParsletCSS::Parser.new
    parser.parse(str)
  rescue Parslet::ParseFailed => error
    puts parser.root.error_tree
  end
end

if __FILE__ == $0
  ParsletCSS.compile(ARGF.read)
end
