<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dspace="http://www.dspace.org/xmlns/dspace/dim" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" version="1.0">
	<!--
     NLM XSLT Crosswalk based on the sample-crosswalk-DIM2DC.xsl.
     The NLM Journal Publishing crosswalk is for disseminating DSpace metadata to
     National Library of Medicine for article indexing.
     
     Author: Jason Stirnaman, jstirnaman@kumc.edu

 Revision: $Revision$
 Date:     $Date$

 -->
<!--
  This stylesheet is used for the final transformation in the NLM PubMed journal publishing pipeline.
  We need to apply the DocType Declaration, but Saxoutputter in the generator won't fire those events 
    so we render it here followed by the raw generator output.
-->

    <xsl:output doctype-public="-//NLM//DTD PubMed 2.0//EN" doctype-system="http://www.ncbi.nlm.nih.gov:80/entrez/query/static/PubMed.dtd" indent="yes"/>
 	  
        <xsl:template match="@* | node()">
        <!--  copy everything by default. -->
                <xsl:copy>
                        <xsl:apply-templates select="@* | node()"/>
                </xsl:copy>

        </xsl:template>

</xsl:stylesheet>