# protect_curly() works

    Code
      cat(as.character(protect_curly(curly$body)))
    Output
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE document SYSTEM "CommonMark.dtd">
      <document xmlns="http://commonmark.org/xml/1.0" sourcepos="1:1-16:20">
        <heading sourcepos="2:1-2:33" level="1">
          <text sourcepos="2:3-2:33" xml:space="preserve">preface </text>
          <text curly="true">{#pre-face .unnumbered}</text>
          <text/>
        </heading>
        <paragraph sourcepos="4:1-4:5">
          <text sourcepos="4:1-4:5" xml:space="preserve">hello</text>
        </paragraph>
        <paragraph sourcepos="6:1-6:51">
          <text sourcepos="6:1-6:51" xml:space="preserve">I like </text>
          <text curly="true">{xml2}</text>
          <text> but of course </text>
          <text curly="true">{tinkr}</text>
          <text> is even cooler!</text>
        </paragraph>
        <paragraph sourcepos="8:1-8:110">
          <text sourcepos="8:1-8:110" xml:space="preserve">Images that use pandoc style will have curlies with content that should be translated and should be protected.</text>
        </paragraph>
        <paragraph sourcepos="10:1-10:88">
          <image sourcepos="10:1-10:51" destination="https://placekitten.com/200/300" title="">
            <text sourcepos="10:3-10:17" xml:space="preserve">a pretty kitten</text>
          </image>
          <text sourcepos="10:52-10:88" xml:space="preserve"/>
          <text curly="true" alt="a picture of a kitten">{#kitteh alt='a picture of a kitten'}</text>
          <text/>
        </paragraph>
        <paragraph sourcepos="12:1-13:17">
          <image sourcepos="12:1-12:47" destination="https://placedog.net/200/300" title="">
            <text sourcepos="12:3-12:16" xml:space="preserve">a pretty puppy</text>
          </image>
          <text sourcepos="12:48-12:68" xml:space="preserve"/>
          <text curly="true" alt="a picture of Mickey's dog">{#dog alt="a picture
      of Mickey's dog"}</text>
          <text/>
          <softbreak/>
        </paragraph>
        <paragraph sourcepos="15:1-16:20">
          <text sourcepos="15:1-15:47" xml:space="preserve"/>
          <text asis="true">[</text>
          <text>a span with attributes</text>
          <text asis="true">]</text>
          <text/>
          <text curly="true">{.span-with-attributes
      style='color: red;'}</text>
          <text/>
          <softbreak/>
        </paragraph>
      </document>

# protect_fences() works

    Code
      cat(as.character(protect_fences(curly$body)))
    Output
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE document SYSTEM "CommonMark.dtd">
      <document xmlns="http://commonmark.org/xml/1.0" sourcepos="1:1-16:18">
        <paragraph sourcepos="2:1-3:20">
          <text sourcepos="2:1-2:25" xml:space="preserve" fence="true">::::: {#special .sidebar}</text>
          <softbreak/>
          <text sourcepos="3:1-3:20" xml:space="preserve">Here is a paragraph.</text>
        </paragraph>
        <paragraph sourcepos="5:1-6:5">
          <text sourcepos="5:1-5:12" xml:space="preserve">And another.</text>
          <softbreak/>
          <text sourcepos="6:1-6:5" xml:space="preserve" fence="true">:::::</text>
        </paragraph>
        <paragraph sourcepos="8:1-8:94">
          <text sourcepos="8:1-8:94" xml:space="preserve">Fenced divs can be nested. Opening fences are distinguished because they must have attributes:</text>
        </paragraph>
        <paragraph sourcepos="10:1-11:18">
          <text sourcepos="10:1-10:18" xml:space="preserve" fence="true">::: Warning ::::::</text>
          <softbreak/>
          <text sourcepos="11:1-11:18" xml:space="preserve">This is a warning.</text>
        </paragraph>
        <paragraph sourcepos="13:1-16:18">
          <text sourcepos="13:1-13:10" xml:space="preserve" fence="true">::: Danger</text>
          <softbreak/>
          <text sourcepos="14:1-14:35" xml:space="preserve">This is a warning within a warning.</text>
          <softbreak/>
          <text sourcepos="15:1-15:3" xml:space="preserve" fence="true">:::</text>
          <softbreak/>
          <text sourcepos="16:1-16:18" xml:space="preserve" fence="true">::::::::::::::::::</text>
        </paragraph>
      </document>

# protect_emojis() works

    Code
      cat(as.character(protect_emojis(ex$body)))
    Output
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE document SYSTEM "CommonMark.dtd">
      <document xmlns="http://commonmark.org/xml/1.0" sourcepos="1:1-15:26">
        <heading sourcepos="1:1-1:12" level="1">
          <text sourcepos="1:3-1:12" xml:space="preserve">Emoji test</text>
        </heading>
        <paragraph sourcepos="3:1-3:19">
          <text sourcepos="3:1-3:19" xml:space="preserve">Hello </text>
          <text emoji="true">:wave:</text>
          <text> world.</text>
        </paragraph>
        <paragraph sourcepos="5:1-5:28">
          <text sourcepos="5:1-5:28" xml:space="preserve"/>
          <text emoji="true">:snake:</text>
          <text> is the Python emoji.</text>
        </paragraph>
        <paragraph sourcepos="7:1-7:36">
          <text sourcepos="7:1-7:36" xml:space="preserve">Multiple emojis: </text>
          <text emoji="true">:smile:</text>
          <text> and </text>
          <text emoji="true">:tada:</text>
          <text>.</text>
        </paragraph>
        <paragraph sourcepos="9:1-9:79">
          <text sourcepos="9:1-9:79" xml:space="preserve">Let me call a tinkr::function without formatting it as code: I am a bad writer.</text>
        </paragraph>
        <paragraph sourcepos="11:1-11:56">
          <text sourcepos="11:1-11:56" xml:space="preserve">In French we put a space before and after ":" : like so.</text>
        </paragraph>
        <paragraph sourcepos="13:1-13:26">
          <text sourcepos="13:1-13:26" xml:space="preserve">The meeting is at 1:30:00.</text>
        </paragraph>
        <paragraph sourcepos="15:1-15:26">
          <text sourcepos="15:1-15:26" xml:space="preserve">This is foo:bar: notation.</text>
        </paragraph>
      </document>

