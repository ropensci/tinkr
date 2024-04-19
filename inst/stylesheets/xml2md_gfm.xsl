<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:md="http://commonmark.org/xml/1.0">


    <!-- Import commonmark XSL -->

    <xsl:import href="xml2md.xsl"/>

    <xsl:template match="/">
        <xsl:apply-imports/>
    </xsl:template>

    <!-- params -->

    <xsl:output method="text" encoding="utf-8"/>

    <xsl:template name="adjust-range">
      <xsl:param name="current" select="0"/>
      <xsl:param name="list" select="0"/>
      <xsl:param name="end" select="0"/>
      <xsl:choose>
        <xsl:when test="contains($list, ' ') and ($current &gt; $end)">
          <xsl:call-template name="adjust-range">
            <xsl:with-param name="current" select="$current"/>
            <xsl:with-param name="list">
              <xsl:call-template name="trim">
                <xsl:with-param name="list" select="$list"/>
              </xsl:call-template>
            </xsl:with-param>
            <xsl:with-param name="end" select="$current + $end"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$list"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:template>

    <xsl:template name="peek">
      <xsl:param name="list" select="0"/>
      <xsl:choose>
        <xsl:when test="contains($list, ' ')">
          <xsl:value-of select="substring-before($list, ' ')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$list"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:template>

    <xsl:template name="trim">
      <xsl:param name="list" select="0"/>
      <xsl:choose>
        <xsl:when test="contains($list, ' ')">
          <xsl:value-of select="substring-after($list, ' ')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$list"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:template>


    <xsl:template name="escape-text-protect">
      <xsl:param name="text"/>
      <xsl:param name="escape" select="'*_`&lt;[]&amp;'"/>
      <xsl:param name="pos" select="1"/>
      <xsl:param name="protect.pos" select="0"/>
      <xsl:param name="protect.end" select="0"/>

      <xsl:variable name="trans" select="translate($text, $escape, '\\\\\\\')"/>
      <xsl:choose>
        <xsl:when test="contains($trans, '\')">
          <xsl:variable name="i" select="substring-before($protect.pos, ' ')"/>
          <xsl:variable name="k" select="substring-before($protect.end, ' ')"/>
          <xsl:variable name="safe" select="substring-before($trans, '\')"/>
          <xsl:variable name="l" select="string-length($safe)"/>
          <xsl:variable name="newpos" select="$pos + $l"/>
          <xsl:variable name="new.pos">
            <xsl:call-template name="adjust-range">
              <xsl:with-param name="current" select="$newpos"/>
              <xsl:with-param name="list" select="$protect.pos"/>
              <xsl:with-param name="end" select="$k"/>
            </xsl:call-template>
          </xsl:variable>
          <xsl:variable name="new.end">
            <xsl:call-template name="adjust-range">
              <xsl:with-param name="current" select="$newpos"/>
              <xsl:with-param name="list" select="$protect.end"/>
              <xsl:with-param name="end" select="$k"/>
            </xsl:call-template>
          </xsl:variable>
          <xsl:variable name="start">
            <xsl:call-template name="peek">
              <xsl:with-param name="list" select="$new.pos"/>
            </xsl:call-template>
          </xsl:variable>
          <xsl:variable name="end">
            <xsl:call-template name="peek">
              <xsl:with-param name="list" select="$new.end"/>
            </xsl:call-template>
          </xsl:variable>
          <xsl:message terminate="no">
            <xsl:text>&#10;safe: </xsl:text>
            <xsl:value-of select="$safe"/>
            <xsl:text>&#10;length: </xsl:text>
            <xsl:value-of select="$l"/>
            <xsl:text>&#9;position: </xsl:text>
            <xsl:value-of select="$newpos"/>
            <xsl:text>&#9;range: </xsl:text>
            <xsl:value-of select="$start"/>
            <xsl:text> .. </xsl:text>
            <xsl:value-of select="$end"/>
            <xsl:text>&#10;positions: </xsl:text>
            <xsl:text>(</xsl:text>
            <xsl:value-of select="$new.pos"/>
            <xsl:text>) </xsl:text>
            <xsl:text> (</xsl:text>
            <xsl:value-of select="$new.end"/>
            <xsl:text>)</xsl:text>
            <xsl:text>&#10;translated: </xsl:text>
            <xsl:value-of select="$trans"/>
            <xsl:text>&#10;</xsl:text>
          </xsl:message>
          <!-- print the first part of the string which needs no escaping -->
          <xsl:value-of select="$safe"/>
          <!-- escape -->
          <xsl:if test="($newpos &lt; $start) or ($newpos &gt; $end)">
            <xsl:message>
              <xsl:text>===>Escaping</xsl:text>
              <xsl:text>&#10;</xsl:text>
            </xsl:message>
            <xsl:text>\</xsl:text>
          </xsl:if>
          <!-- print the escaped character -->
          <xsl:value-of select="substring($text, $l + 1, 1)"/>
          <!-- recurse until the string is complete -->
          <xsl:call-template name="escape-text-protect">
            <xsl:with-param name="text" select="substring($text, $l + 2)"/>
            <xsl:with-param name="escape" select="$escape"/>
            <xsl:with-param name="pos" select="$newpos + 1"/>
            <xsl:with-param name="protect.pos" select="$new.pos"/>
            <xsl:with-param name="protect.end" select="$new.end"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$text"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:template>

      <!-- Text that needs to be preserved (e.g. math/checkboxes) -->

    <xsl:template match="md:text[@protect.pos]">
      <xsl:call-template name="escape-text-protect">
          <xsl:with-param name="text" select="string(.)"/>
          <xsl:with-param name="protect.pos" select="string(@protect.pos)"/>
          <xsl:with-param name="protect.end" select="string(@protect.end)"/>
      </xsl:call-template>
    </xsl:template>

    <xsl:template match="md:emph[@asis='true']">
      <!-- 
        Multiple subscripts in a LaTeX equation will result in emph tags.
        our stylesheet enforces "*" for emph, we are using this workaround
        for aiss emph.
      -->
      <xsl:text>_</xsl:text>
      <xsl:apply-templates select="md:text[@asis='true']"/>
      <xsl:text>_</xsl:text>
    </xsl:template>

    <xsl:template match="md:text[@asis='true']">
      <xsl:value-of select='string(.)'/>
    </xsl:template>

    <xsl:template match="md:link[@rel] | md:image[@rel]">
      <xsl:if test="self::md:image">!</xsl:if>
      <xsl:text>[</xsl:text>
      <!-- use only one set of brackets for links where the key matches the text-->
      <xsl:if test="not(string(self::md:*)=string(@rel))">
        <xsl:apply-templates select="md:*"/>
        <xsl:text>][</xsl:text>
      </xsl:if>
      <xsl:value-of select='string(@rel)'/>
      <xsl:text>]</xsl:text>
    </xsl:template>

    <xsl:template match="md:link[@anchor]">
      <xsl:if test="self::md:image">!</xsl:if>
      <xsl:text>[</xsl:text>
      <xsl:value-of select='string(.)'/>
      <xsl:text>]: </xsl:text>
      <xsl:call-template name="escape-text">
          <xsl:with-param name="text" select="string(@destination)"/>
          <xsl:with-param name="escape" select="'()'"/>
      </xsl:call-template>
      <xsl:if test="string(@title)">
          <xsl:text> "</xsl:text>
          <xsl:call-template name="escape-text">
              <xsl:with-param name="text" select="string(@title)"/>
              <xsl:with-param name="escape" select="'&quot;'"/>
          </xsl:call-template>
          <xsl:text>"</xsl:text>
      </xsl:if>
      <xsl:text>&#10;</xsl:text>
    </xsl:template>

    <xsl:template match="md:tasklist">
      <xsl:apply-templates select="." mode="indent-block"/>
      <xsl:choose>
        <xsl:when test="@completed = 'true'">- [x]</xsl:when>
        <xsl:when test="@completed = 'false'">- [ ]</xsl:when>
      </xsl:choose>
      <xsl:text> </xsl:text>
      <xsl:apply-templates select="md:*"/>
    </xsl:template>

    <xsl:template match="md:item" mode="indent">
      <xsl:text>  </xsl:text>
    </xsl:template>


    <!-- Table -->

    <xsl:template match="md:table">
      <xsl:apply-templates select="." mode="indent-block"/>
      <xsl:apply-templates select="md:*"/>
    </xsl:template>

    <xsl:variable name="minLength">3</xsl:variable>

    <xsl:variable name="maxLength">
      <xsl:for-each select="//md:table_header/md:table_cell">
        <xsl:variable name="pos" select="position()"/>
          <!-- EXslt or XSLT 1.1 would be needed to lookup node-sets;
          thus generating a string (something like CELL1:7|CELL2:5|CELL3:9|CELL4:8|) -->
            <xsl:text>CELL</xsl:text>
            <xsl:value-of select="$pos"/>
            <xsl:text>:</xsl:text>
            <xsl:for-each select="//md:table_cell[position()=$pos]/md:text">
                <xsl:sort data-type="number" select="string-length()" order="descending"/>
                <xsl:if test="position()=1">
                    <xsl:value-of select="string-length()"/>
                    <xsl:value-of select="'|'"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:variable>

    <!-- recursive template to print n dashes/characters -->
    <xsl:template name="n-times">
        <xsl:param name="n"/>
        <xsl:param name="char"/>
        <xsl:if test="$n > 0">
            <xsl:call-template name="n-times">
                <xsl:with-param name="n" select="$n - 1"/>
                <xsl:with-param name="char" select="$char"/>
            </xsl:call-template>
            <xsl:value-of select="$char"/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="md:table_header">
        <xsl:text>| </xsl:text>
        <xsl:apply-templates select="md:*"/>
        <xsl:text>&#xa;| </xsl:text>
        <xsl:for-each select="md:table_cell">
            <!-- helper variable for the lookup -->
            <xsl:variable name="cell" select="concat('CELL',position())"/>
            <!-- length of longest value in col -->
            <xsl:variable name="maxFill" select="number(substring-before(substring-after($maxLength,concat($cell,':')),'|'))"/>
            <xsl:variable name="fill">
                <xsl:choose>
                    <xsl:when test="$maxFill &lt; $minLength">
                        <xsl:value-of select="$minLength"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$maxFill"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:if test="position() != 1">
                <xsl:text> </xsl:text>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="@align = 'right'">
                    <xsl:call-template name="n-times">
                        <xsl:with-param name="n" select="$fill -1"/>
                        <xsl:with-param name="char" select="'-'"/>
                    </xsl:call-template>
                    <xsl:text>: |</xsl:text>
                </xsl:when>
                <xsl:when test="@align = 'left'">
                    <xsl:text>:</xsl:text>
                    <xsl:call-template name="n-times">
                        <xsl:with-param name="n" select="$fill -1"/>
                        <xsl:with-param name="char" select="'-'"/>
                    </xsl:call-template>
                    <xsl:text> |</xsl:text>
                </xsl:when>
                <xsl:when test="@align = 'center'">
                    <xsl:text>:</xsl:text>
                    <xsl:call-template name="n-times">
                        <xsl:with-param name="n" select="$fill -2"/>
                        <xsl:with-param name="char" select="'-'"/>
                    </xsl:call-template>
                    <xsl:text>: |</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="n-times">
                        <xsl:with-param name="n" select="$fill"/>
                        <xsl:with-param name="char" select="'-'"/>
                    </xsl:call-template>
                    <xsl:text> |</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
        <xsl:text>&#xa;</xsl:text>
    </xsl:template>

    <xsl:template match="md:table_cell">
        <xsl:variable name="cell" select="concat('CELL',position())"/>
        <!-- length of longest value in col -->
        <xsl:variable name="maxFill" select="number(substring-before(substring-after($maxLength,concat($cell,':')),'|'))"/>
        <xsl:variable name="fill">
            <xsl:choose>
                <xsl:when test="$maxFill &lt; $minLength">
                    <xsl:value-of select="$minLength - string-length(md:text)"/>
                </xsl:when>
                <xsl:when test="string-length(md:text)=$maxFill">0</xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$maxFill - string-length(md:text)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:apply-templates select="md:*"/>
        <xsl:call-template name="n-times">
            <xsl:with-param name="n" select="$fill"/>
            <xsl:with-param name="char" select="' '"/>
        </xsl:call-template>
        <xsl:text> | </xsl:text>
    </xsl:template>

    <xsl:template match="md:table_row">
        <xsl:text>| </xsl:text>
        <xsl:apply-templates select="md:*"/>
        <xsl:text>&#xa;</xsl:text>
    </xsl:template>

    <xsl:template match="md:table_row">
    <xsl:text>| </xsl:text>
    <xsl:apply-templates select="md:*"/>
    <xsl:text>&#xa;</xsl:text>
</xsl:template>


    <!-- Striked-through -->

    <xsl:template match="md:strikethrough">
        <xsl:text>~~</xsl:text>
        <xsl:apply-templates select="md:*"/>
        <xsl:text>~~</xsl:text>
    </xsl:template>

</xsl:stylesheet>
