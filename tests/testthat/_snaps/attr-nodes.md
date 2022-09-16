# protect_curly() works

    Code
      cat(as.character(protect_curly(curly$body)))
    Output
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE document SYSTEM "CommonMark.dtd">
      <document xmlns="http://commonmark.org/xml/1.0">
        <heading level="1">
          <text xml:space="preserve">preface </text>
          <text curly="true">{#pre-face .unnumbered}</text>
          <text/>
        </heading>
        <paragraph>
          <text xml:space="preserve">hello</text>
        </paragraph>
        <paragraph>
          <text xml:space="preserve">I like </text>
          <text curly="true">{xml2}</text>
          <text> but of course </text>
          <text curly="true">{tinkr}</text>
          <text> is even cooler!</text>
        </paragraph>
        <paragraph>
          <text xml:space="preserve">Images that use pandoc style will have curlies with content that should be translated and should be protected.</text>
        </paragraph>
        <paragraph>
          <image destination="https://placekitten.com/200/300" title="">
            <text xml:space="preserve">a pretty kitten</text>
          </image>
          <text xml:space="preserve"/>
          <text curly="true" alt="a picture of a kitten">{#kitteh alt='a picture of a kitten'}</text>
          <text/>
        </paragraph>
        <paragraph>
          <image destination="https://placedog.net/200/300" title="">
            <text xml:space="preserve">a pretty puppy</text>
          </image>
          <text xml:space="preserve"/>
          <text curly="true" alt="a picture of a dog">{#dog alt="a picture of a dog"}</text>
          <text/>
        </paragraph>
        <paragraph>
          <text xml:space="preserve">[a span with attributes]</text>
          <text curly="true">{.span-with-attributes
      style='color: red;'}</text>
          <text/>
          <softbreak/>
        </paragraph>
      </document>

