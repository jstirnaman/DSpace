<?xml version="1.0" encoding="UTF-8"?>

<!--
  template.xsl

  Version: $Revision: 3705 $

  Date: $Date: 2009-04-11 12:02:24 -0500 (Sat, 11 Apr 2009) $

-->

<!--
    Extensible stylesheet for the Kubrick theme.
    This xsl overrides and extends the dri2xhtml of Manakin, which takes the DRI XML and produces the XHTML for a nice interface with a DSpace repository.
    Some of the overridden templates here just provide new ids and classes on tags to make the css work.  Other overridden templates provide new
    functionality just for Kubrick.  New templates provide new functionality just for Kubrick.
    The purpose of each template is indicated in comments preceding and sometimes inside the template.

    Author: Alexey Maslov
    Author: James Creel

-->
<!--
	Using the stock Kubrick theme.
-->
<xsl:stylesheet xmlns:i18n="http://apache.org/cocoon/i18n/2.1"
	xmlns:dri="http://di.tamu.edu/DRI/1.0/"
	xmlns:mets="http://www.loc.gov/METS/"
	xmlns:xlink="http://www.w3.org/TR/xlink/"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
	xmlns:dim="http://www.dspace.org/xmlns/dspace/dim"
	xmlns:xhtml="http://www.w3.org/1999/xhtml"
	xmlns:mods="http://www.loc.gov/mods/v3"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="i18n dri mets xlink xsl dim xhtml mods dc">

    <xsl:import href="../KUMC.xsl"/>
    <xsl:output indent="yes"/>
    <!-- Overrides the normal document template to organize the structure around a particular div of class "page"-->
    <xsl:template match="dri:document">
        <html>
            <!-- First of all, build the HTML head element -->
            <xsl:call-template name="buildHead"/>
            <!-- Then proceed to the body -->
            <body>
	    	<!-- Here's where the specially classed div gets inserted -->
                <div id="page">
                    <!--
                        The header div, complete with title, subtitle, trail and other junk. The trail is
                        built by applying a template over pageMeta's trail children. -->
                    <xsl:call-template name="buildHeader"/>

                    <!--
                        Goes over the document tag's children elements: body, options, meta. The body template
                        generates the ds-body div that contains all the content. The options template generates
                        the ds-options div that contains the navigation and action options available to the
                        user. The meta element is ignored since its contents are not processed directly, but
                        instead referenced from the different points in the document. -->
                    <xsl:apply-templates />

                    <!--
                        The footer div, dropping whatever extra information is needed on the page. It will
                        most likely be something similar in structure to the currently given example. -->
                    <xsl:call-template name="buildFooter"/>

                </div>
            </body>
        </html>
    </xsl:template>
 </xsl:stylesheet>
