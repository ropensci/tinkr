<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:md="http://commonmark.org/xml/1.0">

    <!-- trim the top of a space-separated list given current and end positions -->
    <xsl:template name="adjust-range">
      <xsl:param name="list" select="0"/>
      <xsl:param name="current" select="0"/>
      <xsl:param name="end" select="0"/>
      <xsl:choose>
        <!-- when the list can be trimmed and we are out of range, trim it -->
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
        <!-- either we are in range or the list cannot be trimmed, return the list -->
        <xsl:otherwise>
          <xsl:value-of select="$list"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:template>

    <!-- get the top value of a space-separated list -->
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

    <!-- remove the top value of a space-separated list -->
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


    <!-- escape text except for protected text -->
    <xsl:template name="escape-text-protect">
      <xsl:param name="text"/>
      <!-- a set of characters to escape (note that / is implied) -->
      <xsl:param name="escape" select="'*_`&lt;[]&amp;'"/>
      <!-- the current position of the text string (defaults to 1) -->
      <xsl:param name="pos" select="1"/>
      <!-- a space-separated list of starting positions to protect (defaults to 0) -->
      <xsl:param name="protect.pos" select="0"/>
      <!-- a space-separated list of ending positions to protect (defaults to 0) -->
      <xsl:param name="protect.end" select="0"/>

      <xsl:variable name="trans" select="translate($text, $escape, '\\\\\\\')"/>
      <xsl:choose>
        <xsl:when test="contains($trans, '\')">
          <xsl:variable name="safe" select="substring-before($trans, '\')"/>
          <xsl:variable name="l" select="string-length($safe)"/>
          <xsl:variable name="newpos" select="$pos + $l"/>
          <!-- Determine if we need to advance the protected range 
            If the current end of the range (k) is less than the current
            position, then it is outdated and we need to update, but only if
            there continues to be range to update, which is why we pass it
            into `adjust-range`.

            NOTE: XPATH cannot "update" variables, it can only create new ones,
            which is why we are using templates. 
          --> 
          <xsl:variable name="k" select="substring-before($protect.end, ' ')"/>
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
          <!-- Get the current range of protection -->
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
          <!-- print the first part of the string which needs no escaping -->
          <xsl:value-of select="$safe"/>
          <!-- escape if we are in range -->
          <xsl:if test="($newpos &lt; $start) or ($newpos &gt; $end)">
            <xsl:text>\</xsl:text>
          </xsl:if>
          <!-- print the escaped character -->
          <xsl:value-of select="substring($text, $l + 1, 1)"/>
          <!-- recurse until the string is complete -->
          <xsl:call-template name="escape-text-protect">
            <xsl:with-param name="text" select="substring($text, $l + 2)"/>
            <xsl:with-param name="escape" select="$escape"/>
            <!-- do not forget to advance the position -->
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

</xsl:stylesheet>
