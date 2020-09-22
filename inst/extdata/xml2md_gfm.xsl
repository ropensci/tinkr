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


  <!-- Table -->

    <xsl:template match="md:table">
        <xsl:apply-templates select="." mode="indent-block"/>
        <xsl:apply-templates select="md:*"/>
    </xsl:template>

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
        <xsl:text>&#xa; | </xsl:text>
        <xsl:for-each select="md:table_cell">
            <!-- helper variable for the lookup -->
            <xsl:variable name="cell" select="concat('CELL',position())"/>
            <!-- length of longest value in col -->
            <xsl:variable name="fill" select="number(substring-before(substring-after($maxLength,concat($cell,':')),'|'))"/>
            <xsl:choose>
                <xsl:when test="@align = 'right'">
                    <xsl:text> </xsl:text>
                    <xsl:call-template name="n-times">
                        <xsl:with-param name="n" select="$fill"/>
                        <xsl:with-param name="char" select="'-'"/>
                    </xsl:call-template>
                    <xsl:text>: |</xsl:text>
                </xsl:when>
                <xsl:when test="@align = 'left'">
                    <xsl:text> :</xsl:text>
                    <xsl:call-template name="n-times">
                        <xsl:with-param name="n" select="$fill"/>
                        <xsl:with-param name="char" select="'-'"/>
                    </xsl:call-template>
                    <xsl:text> |</xsl:text>
                </xsl:when>
                <xsl:when test="@align = 'center'">
                    <xsl:text> :</xsl:text>
                    <xsl:call-template name="n-times">
                        <xsl:with-param name="n" select="$fill"/>
                        <xsl:with-param name="char" select="'-'"/>
                    </xsl:call-template>
                    <xsl:text>: |</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text> </xsl:text>
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
    <xsl:apply-templates select="md:*"/>
    <xsl:text>| </xsl:text>
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
