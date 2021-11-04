<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text" encoding="UTF-8" />
    <xsl:strip-space elements="*" />
    <xsl:variable name="delimitor" select="','" />
    <xsl:variable name="newline" select="'&#10;'" />
    <xsl:template name='data' match="/configuration">
        <xsl:text>LUN,</xsl:text>
        <xsl:for-each select="physical_partition[1]/partition[@label='system_a']/@*">
            <xsl:value-of select="name()" />
            <xsl:value-of select="$delimitor" />
        </xsl:for-each>
        <xsl:value-of select="$newline" />
        <xsl:for-each select="physical_partition">
            <xsl:variable name="comments">
                <!-- <xsl:value-of select='preceding-sibling::comment()[1]' /> -->
                <xsl:analyze-string select="preceding-sibling::comment()[1]" regex="LUN(\s?)[0-9]">
                    <xsl:matching-substring>
                        <xsl:sequence select="."/>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:variable>
            <xsl:for-each select="partition">
                <xsl:copy-of select="$comments" />
                <xsl:value-of select="$delimitor" />
                <xsl:for-each select="@*">
                    <xsl:value-of select="current()" />
                    <xsl:value-of select="$delimitor" />
                </xsl:for-each>
                <xsl:value-of select="$newline" />
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>