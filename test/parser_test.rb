require 'minitest/autorun'
require 'parslet-css'

describe ParsletCSS::Parser do
  before do
    @parser = ParsletCSS::Parser.new
  end

  describe "import parse" do
    it "can import other css" do
      @parser.parse('@import "mystyle.css";')
      @parser.parse('@import url("mystyle.css");')
      @parser.parse('@import url("bluish.css") projection, tv;')
      @parser.parse('@import url("fineprint.css") print; @import url("bluish.css") projection, tv; body {}')
    end
  end

  describe "charset" do
    it '@charset rule must place the rule at the very beginning of the style sheet' do
      @parser.parse('@charset "ISO-8859-1";')
      @parser.parse('@charset "UTF-8"; @import "mystyle.css"; body {}')
    end
  end

  describe "parse success" do
    it "parse with percent" do
      @parser.parse("body { height: 100%; width: 100%; }")
    end
    it "with url" do
      @parser.parse("body { background: url(/images/plop.png); }")
      @parser.parse("body { background: url(https://localhost:3000/images/plop.png); }")
      @parser.parse("body { background: url(/~spk/images/plop.png?size=30;toto=tata); }")
      @parser.parse("body { background: url(/~spk/images/plop.png?size=30&toto=tata); }")
      u = @parser.parse("body { background: url(/up.png); } nav { background: url(/nav.png) }")
      assert_equal(2, u.size)
    end
    it "with comments" do
      @parser.parse("body { /* comment */ padding: 0; /* comment */}")
    end
    it "with no space" do
      @parser.parse(":focus{outline:0;/*comment*/}")
      @parser.parse(":focus{outline:0}")
    end
    it "with no last semicolon" do
      @parser.parse("body { height: 100%; width: 100% }")
    end
    it "with one property and no semicolon" do
      @parser.parse("body { width: 100% }")
    end
    it "with blank property" do
      @parser.parse("body { }")
    end
    it 'with color' do
      @parser.parse("body { color: #1a171b; }")
      @parser.parse("body { color: #fff; }")
    end
    it 'with font family' do
      @parser.parse("body { font: 12px monospace, serif; }")
      @parser.parse("body { font: bold 14px/28px Arial; }")
    end
    it 'with multiple property values' do
      @parser.parse("body { margin: 10px 10px 10px 10em;}")
      @parser.parse("body { background: url(/images/ui/down.png) no-repeat scroll 140px 0px transparent; }")
      @parser.parse("body { background: url(/images/ui/up.png) no-repeat scroll 140px 0px #1a171b; }")
    end
    it "float size" do
      @parser.parse(".date_selector .nav { width: 17.5em; }")
    end
    it 'property priority' do
      @parser.parse(".date_selector .nav { width: 17.5em !important; }")
    end
  end

  describe "parse fail" do
    # http://www.w3.org/TR/CSS21/syndata.html#parsing-errors
    @raises = [
      {:msg => "with extra semicolon", :css => "body { height: 100%; ; width: 100%; }"},
      {:msg => "with extra curly", :css => "body { height: 100%; width: 100%; }}"},
      {:msg => "& is not valid token", :css => "h3, h4 & h5 {color: red }"},
      {:msg => "1 malformed declaration missing ':', value", :css => "p { color:green; color }"},
      {:msg => "2 malformed declaration missing value", :css => "p { color:green; color: }"},
      {:msg => "unexpected tokens { }", :css => "p { color:green; color{;color:maroon} }"},
      {:msg => "ruleset with unexpected at-keyword @here", :css => "p @here {color: red}"},
      {:msg => "at-rule with unexpected at-keyword @bar", :css => "@foo @bar;"},
      {:msg => "ruleset with unexpected right brace", :css => "}} {{ - }}"},
      {:msg => "ruleset with unexpected right parenthesis", :css => ") ( {} ) p {color: red }"},

      # http://www.w3.org/TR/CSS2/syndata.html#at-rules
      {:msg => "must ignore any '@import' rule that occurs inside a block",
        :css => '@import "subs.css"; h1 { color: blue } @import "list.css";'},
      {:msg => 'non valid charset', :css => '@charset "none";'},
      {:msg => '@charset rule not at the beginning of the style sheet',
        :css => '@import "awesome.css"; @charset "UTF-8";'},
    ]
    @raises.each do |r|
      class_eval do
        it r[:msg] do
          assert_raises Parslet::ParseFailed do
            @parser.parse(r[:css])
          end
        end
      end
    end

  end
end
