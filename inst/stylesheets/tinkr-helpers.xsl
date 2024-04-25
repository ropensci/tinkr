<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:str="http://exslt.org/strings"
    xmlns:md="http://commonmark.org/xml/1.0">

    <!-- escape text except for protected text -->
    <xsl:template name="escape-text-protect">
      <xsl:param name="text"/>
      <!-- a set of characters to escape (note that / is implied) -->
      <xsl:param name="escape" select="'*_`&lt;[]&amp;'"/>
      <!-- the current position of the text string (defaults to 1) -->
      <xsl:param name="pos" select="1"/>
      <!-- the index of the current protection -->
      <xsl:param name="index" select="1"/>
      <!-- nodeset of tokens generated from tokenizing a list of numbers -->
      <xsl:param name="protect.pos" select="0"/>
      <!-- nodeset of tokens generated from tokenizing a list of numbers -->
      <xsl:param name="protect.end" select="0"/>


      <xsl:variable name="trans" select="translate($text, $escape, '\\\\\\\')"/>
      <xsl:choose>
        <xsl:when test="contains($trans, '\')">
          <xsl:variable name="safe" select="substring-before($trans, '\')"/>
          <xsl:variable name="l" select="string-length($safe)"/>
          <xsl:variable name="newpos" select="$pos + $l"/>
          <!-- Update the index variable for the protection -->
          <!-- NOTE: it's strange, but the value of the index must be converted to -->
          <!-- a number with a math operation -->
          <xsl:variable name="idx">
            <xsl:choose>
              <!-- when the index is at the end of the list, we increment no more -->
              <xsl:when test="count($protect.end) = $index">
                <xsl:value-of select="$index + 0"/>
              </xsl:when>
              <!-- if our position extends beyond the boundary of the last protection, we increment -->
              <xsl:when test="$newpos &gt; $protect.end[$index + 0]">
                <xsl:value-of select="$index + 1"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$index + 0"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <!-- create a start and end variable for testing -->
          <xsl:variable name="start" select="$protect.pos[$idx + 0]"/>
          <xsl:variable name="end" select="$protect.end[$idx + 0]"/>

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
            <xsl:with-param name="index" select="$idx"/>
            <xsl:with-param name="protect.pos" select="$protect.pos"/>
            <xsl:with-param name="protect.end" select="$protect.end"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$text"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
