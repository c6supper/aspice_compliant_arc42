<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs">
    <xsl:output method="text" encoding="UTF-8" />
    <xsl:strip-space elements="*" />
    <xsl:variable name="delimitor" select="','" />
    <xsl:variable name="newline" select="'&#xd;&#xa;'" />
    <xsl:template name='data' match="/configuration">
        <!-- <xsl:text>LUN,</xsl:text> -->
        <!-- <xsl:variable name="column_count">
            <xsl:value-of select="count(physical_partition[1]/partition[@label='la_userdata']/@*)"></xsl:value-of>
        </xsl:variable> -->
        <xsl:variable name="column_names" as="element()*">
            <Item>LUN</Item>
            <Item>label</Item>
            <Item>size_in_kb</Item>
            <Item>type</Item>
            <Item>bootable</Item>
            <Item>readonly</Item>
            <Item>filename</Item>
            <Item>system</Item>
            <Item>sparse</Item>
        </xsl:variable>

        <xsl:for-each select="$column_names">
            <xsl:value-of select="." />
            <xsl:if test="position() != last()">
                <xsl:value-of select="$delimitor" />
            </xsl:if>
        </xsl:for-each>

        <!-- <xsl:for-each select="physical_partition[1]/partition[@label='la_userdata']/@*">
            <xsl:value-of select="name()" />
            <xsl:if test="position() != last()">
                <xsl:value-of select="$delimitor" />
            </xsl:if>
        </xsl:for-each> -->
        <xsl:value-of select="$newline" />
        <xsl:for-each select="physical_partition">
            <xsl:variable name="lun">
                <!-- <xsl:value-of select='preceding-sibling::comment()[1]' /> -->
                <xsl:analyze-string select="preceding-sibling::comment()[1]" regex="LUN(\s?)[0-9]">
                    <xsl:matching-substring>
                        <xsl:sequence select="."/>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:variable>
            <xsl:for-each select="partition">
                <xsl:copy-of select="$lun" />
                <xsl:value-of select="$delimitor" />

                <xsl:value-of select="@label"/>
                <xsl:value-of select="$delimitor" />

                <xsl:value-of select="@size_in_kb"/>
                <xsl:value-of select="$delimitor" />

                <xsl:value-of select="@type"/>
                <xsl:value-of select="$delimitor" />

                <xsl:value-of select="@bootable"/>
                <xsl:value-of select="$delimitor" />

                <xsl:value-of select="@readonly"/>
                <xsl:value-of select="$delimitor" />

                <xsl:value-of select="@filename"/>
                <xsl:value-of select="$delimitor" />

                <xsl:value-of select="@system"/>
                <xsl:value-of select="$delimitor" />

                <xsl:value-of select="@sparse"/>

                <xsl:value-of select="$newline" />
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>