# protect_curly() works

    Code
      cat(as.character(protect_curly(curly$body)))
    Output
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE document SYSTEM "CommonMark.dtd">
      <document xmlns="http://commonmark.org/xml/1.0" sourcepos="1:1-16:20">
        <heading sourcepos="2:1-2:33" level="1">
          <text sourcepos="2:3-2:33" xml:space="preserve" curly-id="1" protect.start="9" protect.end="31" curly="9:31">preface {#pre-face .unnumbered}</text>
        </heading>
        <paragraph sourcepos="4:1-4:5">
          <text sourcepos="4:1-4:5" xml:space="preserve">hello</text>
        </paragraph>
        <paragraph sourcepos="6:1-6:51">
          <text sourcepos="6:1-6:51" xml:space="preserve" curly-id="2" protect.start="8 29" protect.end="13 35" curly="8 29:13 35">I like {xml2} but of course {tinkr} is even cooler!</text>
        </paragraph>
        <paragraph sourcepos="8:1-8:110">
          <text sourcepos="8:1-8:110" xml:space="preserve">Images that use pandoc style will have curlies with content that should be translated and should be protected.</text>
        </paragraph>
        <paragraph sourcepos="10:1-10:88">
          <image sourcepos="10:1-10:51" destination="https://placekitten.com/200/300" title="">
            <text sourcepos="10:3-10:17" xml:space="preserve">a pretty kitten</text>
          </image>
          <text sourcepos="10:52-10:88" xml:space="preserve" curly-id="3" asis="true" curly="true" alt="'a picture of a kitten'">{#kitteh alt='a picture of a kitten'}</text>
        </paragraph>
        <paragraph sourcepos="12:1-13:10">
          <image sourcepos="12:1-12:47" destination="https://placedog.net/200/300" title="">
            <text sourcepos="12:3-12:16" xml:space="preserve">a pretty puppy</text>
          </image>
          <text sourcepos="12:48-12:68" xml:space="preserve" curly-id="4" asis="true" curly="true" alt="&quot;a picture of a dog&quot;">{#dog alt="a picture</text>
          <softbreak curly-id="4"/>
          <text sourcepos="13:1-13:10" xml:space="preserve" curly-id="4" asis="true" curly="true">of a dog"}</text>
        </paragraph>
        <paragraph sourcepos="15:1-16:20">
          <text sourcepos="15:1-15:47" xml:space="preserve" protect.start="1 24 25" protect.end="1 24 46" curly-id="5" curly="25:46">[a span with attributes]{.span-with-attributes</text>
          <softbreak curly-id="5"/>
          <text sourcepos="16:1-16:20" xml:space="preserve" curly-id="5" asis="true" curly="true">style='color: red;'}</text>
        </paragraph>
      </document>

# multiline alt text can be processed

    Code
      cat(as.character(protect_curly(curly$body)))
    Output
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE document SYSTEM "CommonMark.dtd">
      <document xmlns="http://commonmark.org/xml/1.0" sourcepos="1:1-21:64">
        <heading sourcepos="2:1-2:33" level="1">
          <text sourcepos="2:3-2:33" xml:space="preserve" curly-id="1" protect.start="9" protect.end="31" curly="9:31">preface {#pre-face .unnumbered}</text>
        </heading>
        <paragraph sourcepos="4:1-4:5">
          <text sourcepos="4:1-4:5" xml:space="preserve">hello</text>
        </paragraph>
        <paragraph sourcepos="6:1-6:51">
          <text sourcepos="6:1-6:51" xml:space="preserve" curly-id="2" protect.start="8 29" protect.end="13 35" curly="8 29:13 35">I like {xml2} but of course {tinkr} is even cooler!</text>
        </paragraph>
        <paragraph sourcepos="8:1-8:110">
          <text sourcepos="8:1-8:110" xml:space="preserve">Images that use pandoc style will have curlies with content that should be translated and should be protected.</text>
        </paragraph>
        <paragraph sourcepos="10:1-10:88">
          <image sourcepos="10:1-10:51" destination="https://placekitten.com/200/300" title="">
            <text sourcepos="10:3-10:17" xml:space="preserve">a pretty kitten</text>
          </image>
          <text sourcepos="10:52-10:88" xml:space="preserve" curly-id="3" asis="true" curly="true" alt="'a picture of a kitten'">{#kitteh alt='a picture of a kitten'}</text>
        </paragraph>
        <paragraph sourcepos="12:1-13:10">
          <image sourcepos="12:1-12:47" destination="https://placedog.net/200/300" title="">
            <text sourcepos="12:3-12:16" xml:space="preserve">a pretty puppy</text>
          </image>
          <text sourcepos="12:48-12:68" xml:space="preserve" curly-id="4" asis="true" curly="true" alt="&quot;a picture of a dog&quot;">{#dog alt="a picture</text>
          <softbreak curly-id="4"/>
          <text sourcepos="13:1-13:10" xml:space="preserve" curly-id="4" asis="true" curly="true">of a dog"}</text>
        </paragraph>
        <paragraph sourcepos="15:1-19:23">
          <text sourcepos="15:1-15:47" xml:space="preserve" protect.start="1 24 25" protect.end="1 24 46" curly-id="5" curly="25:46">[a span with attributes]{.span-with-attributes</text>
          <softbreak curly-id="5"/>
          <text sourcepos="16:1-16:20" xml:space="preserve" curly-id="5" asis="true" curly="true">style='color: red;'}</text>
          <softbreak/>
          <image sourcepos="17:1-17:38" destination="image.png" title="">
            <text sourcepos="17:3-17:26" xml:space="preserve">image with long alt text</text>
          </image>
          <text sourcepos="17:39-17:58" xml:space="preserve" curly-id="6" asis="true" curly="true" alt="'this is long alt text that should be all included in the image'">{#image alt='this is</text>
          <softbreak curly-id="6"/>
          <text sourcepos="18:1-18:32" xml:space="preserve" curly-id="6" asis="true">long alt text that should be all</text>
          <softbreak curly-id="6"/>
          <text sourcepos="19:1-19:23" xml:space="preserve" curly-id="6" asis="true" curly="true">included in the image'}</text>
        </paragraph>
        <paragraph sourcepos="21:1-21:64">
          <image sourcepos="21:1-21:37" destination="img.png" title="">
            <text sourcepos="21:3-21:27" xml:space="preserve">image with short alt text</text>
          </image>
          <text sourcepos="21:38-21:64" xml:space="preserve" curly-id="7" asis="true" curly="true" alt="'short alt text'">{#img alt='short alt text'}</text>
        </paragraph>
      </document>

