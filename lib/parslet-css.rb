# encoding: UTF-8
require 'parslet'
require 'parslet-css/version'

class ParsletCSS
  autoload :Parser, 'parslet-css/parser'

  def self.compile(str)
    parser = ParsletCSS::Parser.new
    parser.parse(str)
  rescue Parslet::ParseFailed => error
    puts parser.root.error_tree
    parser
  end
end

if __FILE__ == $0
  ParsletCSS.compile(ARGF.read)
end
