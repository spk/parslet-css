# encoding: UTF-8
require 'minitest/autorun'
require 'parslet-css'

describe ParsletCSS::Parser do
  before do
    @parser = ParsletCSS::Parser.new
  end

  describe "Annotate" do
    it 'can have import' do
      res = @parser.parse('@import "mystyle.css" projection, tv; @import url("mystyle.css") print;')
      assert_equal(res.first[:import], 'mystyle.css')
      assert_equal(res.first[:media_type_list], 'projection, tv')
      assert_equal(res.last[:import], {:url => "mystyle.css"})
      assert_equal(res.last[:media_type_list], 'print')
    end
    it 'can have charset' do
      res = @parser.parse('@charset "ISO-8859-1";')
      assert_equal(res[:charset], 'ISO-8859-1')
    end
    it 'can have urls' do
      res = @parser.parse("body { background: url(/up.png); } nav { background: url(/nav.png) }")
      assert_equal(res.first[:url], '/up.png')
      assert_equal(res.last[:url], '/nav.png')
      assert_equal(res.size, 2)
    end
    it 'can have media' do
      res = @parser.parse('@media screen, print { body { font-size: 13px } }')
      assert_equal(res.first[:media], 'screen, print')
    end
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

  describe '@media rule' do
    it 'valid statement' do
      @parser.parse('@media print { body { font-size: 10pt } }')
      @parser.parse('@media screen, print { body { font-size: 13px } }')
      @parser.parse('/* print */ @media print { body { font-size: 10pt } }
                     /* screen */ @media screen { body { font-size: 13px } }')
    end
  end

  describe "parse success" do
    it "parse margin" do
      @parser.parse("body { margin: 0 auto; }")
      @parser.parse("body { margin: 10px 10px 0 0;}")
    end

    it "parse with percent" do
      @parser.parse("body { height: 100%; width: 100%; }")
    end
    it "with url" do
      @parser.parse("body { background: url(/images/plop.png); }")
      @parser.parse("body { background: url(https://localhost:3000/images/plop.png); }")
      @parser.parse("body { background: url(/~spk/images/plop.png?size=30;toto=tata); }")
      @parser.parse("body { background: url(/~spk/images/plop.png?size=30&toto=tata); }")
      @parser.parse("body { background: url(/up.png); } nav { background: url(/nav.png) }")
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

    describe('CSS selectors') do
      # http://www.w3.org/TR/CSS2/selector.html
      it "CSS2 w3c examples" do
        # 5.2.1 Grouping
        @parser.parse("h1, h2, h3 { font-family: sans-serif }")
        # 5.6 Child selectors
        @parser.parse("body > P { line-height: 1.3 }")
        @parser.parse("div ol>li p { font: 2px }")
        # 5.7 Adjacent sibling selectors
        @parser.parse("math + p { text-indent: 0 } ")
        @parser.parse("h1 + h2 { margin-top: -5mm }")
        @parser.parse("h1.opener + h2 { margin-top: -5mm }")
        # 5.8.1 Matching attributes and attribute values
        @parser.parse("h1[title] { color: blue; }")
        @parser.parse("span[class=example] { color: blue; }")
        @parser.parse('span[hello="Cleveland"][goodbye="Columbus"] { color: blue; }')
        @parser.parse('a[rel~="copyright"] {}')
        @parser.parse('a[href="http://www.w3.org/"] {}')
        @parser.parse("*[lang=fr] { display : none }")
        @parser.parse('*[lang|="en"] { color : red }')
        @parser.parse('DIALOGUE[character=juliet] { voice-family: "Vivien Leigh", victoria, female }')
        # 5.8.3 Class selectors
        @parser.parse("*.pastoral { color: green }")
        @parser.parse("H1.pastoral { color: green }")
        @parser.parse('p.marine.pastoral { color: green }')
        # 5.9 ID selectors
        @parser.parse("h1#chapter1 { text-align: center }")
        # 5.11 Pseudo-classes
        @parser.parse('div > p:first-child { text-indent: 0 }')
        @parser.parse('p:first-child em { font-weight : bold }')
        @parser.parse('* > a:first-child {} /* A is first child of any element */')
        @parser.parse('a:first-child {} /* Same */')
        @parser.parse(':link { color: red }')
        @parser.parse('a.external:visited { color: blue }')
        @parser.parse('a:focus:hover { background: white }')
        # 5.11.4 The language pseudo-class: :lang
        @parser.parse("html:lang(fr-ca) { quotes: '« ' ' »' }")
        @parser.parse(":lang(fr) > Q { quotes: '« ' ' »' }")
        # 5.12.1 The :first-line pseudo-element
        @parser.parse("p:first-line { text-transform: uppercase }")
        @parser.parse('p:first-letter { font-size: 3em; font-weight: normal }')
        # 5.12.3 The :before and :after pseudo-elements
        @parser.parse('p.special:before {content: "Special! "}')
        @parser.parse('p.special:first-letter {color: #ffd800}')
      end

      # http://www.w3.org/TR/css3-selectors/
      it "CSS3 w3c examples" do
        @parser.parse('object[type^="image/"] {}')
        @parser.parse('a[href$=".html"] {}')
        @parser.parse('tr:nth-child(2n+1) {} /* represents every odd row of an HTML table */')
        @parser.parse('p:nth-child(4n+1) { color: navy; }')
        @parser.parse('button:not([DISABLED]) {}')
        @parser.parse('p::first-line { text-transform: uppercase }')
      end
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

      {:msg => 'identifier must not be empty. (Otherwise, the selector is invalid.)',
        :css => 'html:lang() {}'},
      {:msg => 'margin non valid values',
        :css => "body { margin: 10px 10px 10px transparent;}"}
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
