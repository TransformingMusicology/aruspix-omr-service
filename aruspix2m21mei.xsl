<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:mei="http://www.music-encoding.org/ns/mei"
    xmlns:local="http://localhost"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    exclude-result-prefixes="xs"
    version="2.0">
    <xsl:variable name="local:duration-equivalents">
        <durations>
            <longa>long</longa>
            <brevis>breve</brevis>
            <semibrevis>1</semibrevis>
            <minima>2</minima>
            <semiminima>4</semiminima>
            <fusa>8</fusa>
            <semifusa>16</semifusa>
        </durations>
    </xsl:variable>
    <!--Identity template, 
        provides default behavior that copies all content into the output -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="processing-instruction('xml-model')"></xsl:template>
    <xsl:template match="mei:pages">
        <mei:score>
            <xsl:apply-templates select="node()"/>
        </mei:score>
    </xsl:template>
    <xsl:template match="mei:page">
            <xsl:apply-templates select="node()"/>
    </xsl:template>
    <xsl:template match="mei:system">
        <mei:section>
            <mei:measure>
                <xsl:attribute name="n" select="count(preceding::mei:system)+1" />
                <xsl:apply-templates select="node()"/>
            </mei:measure>
        </mei:section>
    </xsl:template>
    <xsl:template match="@xml:id"/>
    <xsl:template match="mei:staff">
        <xsl:copy>
			<xsl:apply-templates select="@*"/>
            <xsl:element name="mei:staffDef">
				<xsl:attribute name="n" select="./@n"/>
				<xsl:attribute name="lines" select="5"/>
			</xsl:element>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="@meiversion">
        <xsl:attribute name="meiversion" select="'3.0.0'"/>
    </xsl:template>
    <xsl:template match="@meiversion.num"/>
    <xsl:template match="@dur">
        <xsl:variable name="d" select="."/>
        <xsl:attribute name="dur" select="$local:duration-equivalents/durations/*[name(.)=$d]/text()" />
    </xsl:template>
</xsl:stylesheet>
