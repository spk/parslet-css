class ParsletCSS::Parser < Parslet::Parser
  # TODO: be mo precise with selectors
  rule(:selectors) { ignore >> match('[^{]').repeat }
  rule(:lcurly) { ignore >> str('{') >> ignore }
  rule(:declarations) { (declaration >> semicolon?).repeat }
  rule(:declaration) {
    ignore >> name >> ignore >> str(':') >>
    ignore >> property_values >> ignore
  }

  rule(:property_values) {
    property_value >> (semicolon.absent? >> space >> property_value).repeat(0, 5)
  }
  # TODO: be more precise for margin, padding... property values
  rule(:property_value) {
    font_height | property_value_keywords | uri | percent | color | size | font_family_list
  }
  rule(:property_value_keywords) {
    str('no-repeat') | str('scroll') | str('inherit') |
    str('baseline') | str('block') | str('both') | str('bold') |
    str('inline-block') | str('inline')
  }

  # URL
  # http://labs.apache.org/webarch/uri/rev-2002/rfc2396bis.html#collected-abnf
  rule(:uri) { str('url(') >> quote? >> url.as(:url) >> quote? >> str(')') }
  rule(:url) { protocol? >> domain? >> path }
  rule(:protocol) {
    (str('https') | str('http') | str('ftp') | str('gopher') | str('mailto') |
     str('news') | str('nntp') | str('telnet') | str('wais') | str('file') |
     str('prospero')) >> str('://')
  }
  rule(:protocol?) { protocol.maybe }
  rule(:domain) { match('[a-zA-Z0-9\-\._\/]').repeat >> (str(':') >> integer).maybe }
  rule(:domain?) { domain.maybe }
  rule(:path) { path_chars >> query? }
  rule(:path_chars) { (str('/').maybe >> match('[a-zA-Z0-9\-\._~]')).repeat }
  rule(:query) {
    str('?') >> (query_key_value >> (query_sep >> query_key_value).repeat).maybe
  }
  rule(:query_sep) { str('&') | semicolon }
  rule(:query?) { query.maybe }
  rule(:query_key_value) { name >> str('=') >> name }

  rule(:percent) { sign? >> integer >> str('%') }
  rule(:size) { sign? >> (float | integer) >> length_unit }
  rule(:length_unit) {
    str('em') | str('ex') | str('px') | str('in') |
    str('cm') | str('mm') | str('pt') | str('pc')
  }

  # http://www.w3.org/TR/2002/WD-css3-fonts-20020802/#font-family-prop
  rule(:font_family_list) {
    font_family >> ((str(',') >> space? >> font_family).repeat).maybe
  }
  # Font family names containing whitespace [link to syntax module] should be quoted.
  rule(:font_family) {
    quote >> match('[a-zA-Z0-9\-_\. ]').repeat >> quote | name
  }
  rule(:font_height) {
    size >> str('/') >> size
  }

  # COLORS
  rule(:color) { color_keywords | hex_value | rgb }
  rule(:color_keywords) {
    str('aqua') | str('black') | str('blue') | str('fuchsia') | str('gray') |
    str('green') | str('lime') | str('maroon') | str('navy') | str('olive') |
    str('purple') | str('red') | str('silver') | str('teal') | str('white') |
    str('yellow') | str('transparent')
  }
  rule(:hex_value) {
    str('#') >> (digit_hex.repeat(6,6) | digit_hex.repeat(3,3))
  }
  rule(:digit_hex) { match('[0-9a-fA-F]') }
  rule(:rgb) {
    (str('rgb(') | str('rgba(') | str('hsl(')) >>
    space? >> rgb_value >> space? >> str(',') >>
    space? >> rgb_value >> space? >> str(',') >>
    (space? >> rgb_value >> space? >> str(',')).maybe >>
    space? >> rgb_value >> space? >> str(')')
  }
  rule(:rgb_value) { percent | float | integer }

  rule(:rcurly) { ignore >> str('}') >> ignore }

  rule(:space) { match('\s').repeat(1) }
  rule(:space?) { space.maybe }
  rule(:quote) { str('"') | str("'") }
  rule(:quote?) { quote.maybe }
  rule(:name) { match['_a-zA-Z0-9-'].repeat }
  rule(:integer) { match('[0-9]').repeat }
  rule(:float) { integer >> str('.') >> integer }
  rule(:semicolon) { str(';') }
  rule(:semicolon?) { semicolon.maybe }
  rule(:sign) { str('+') | str('-') }
  rule(:sign?) { sign.maybe }
  rule(:comment) { space? >> (str('/*') >> (str('*/').absent? >> any).repeat >> str('*/')) >> space? }
  rule(:ignore) { comment | space? }

  rule(:ruleset) { selectors >> lcurly >> declarations >> rcurly }
  rule(:stylesheet) { ruleset.repeat }
  root :stylesheet
end