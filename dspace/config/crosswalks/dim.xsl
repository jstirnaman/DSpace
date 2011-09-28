<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:dspace="http://www.dspace.org/xmlns/dspace/dim"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns:dcterms="http://purl.org/dc/terms/"
                version="1.0">
<!--
        Incomplete proof-of-concept Example of
        XSLT crosswalk from DIM (DSpace Intermediate Metadata) to
        Qualified Dublin Core.
         by William Reilly, aug. 05; mutilated by Larry Stone.

        This is only fit for a simple smoke test of the XSLT-based
        crosswalk plugin, do not use it for anthing more serious.

 Revision: $Revision$
 Date:     $Date$

 -->

        <xsl:template match="@* | node()">
        <!--  copy everything by default. -->
                <xsl:copy>
                        <xsl:apply-templates select="@* | node()"/>
                </xsl:copy>

        </xsl:template>
</xsl:stylesheet>
