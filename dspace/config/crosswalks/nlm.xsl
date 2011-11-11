<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dspace="http://www.dspace.org/xmlns/dspace/dim" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" version="1.0">
	<!--
     NLM XSLT Crosswalk based on the sample-crosswalk-DIM2DC.xsl.
     The NLM Journal Publishing crosswalk is for disseminating DSpace metadata to
     National Library of Medicine for journal indexing.
     Author: Jason Stirnaman, jstirnaman@kumc.edu

 Revision: $Revision$
 Date:     $Date$

 -->
	<!-- Journal -->
	<!-- Publisher -->
	<!-- Get Journal Title, Issn, Volume, and Issue from Relation:isPartOf -->
	<!-- PubDate -->
	<!-- Article details -->
	<!-- Only match "ITEM" nodes that have dc.type=Article. This omits Tables of Contents items from output
     since they have a different dc.type.
-->
<!-- Ideally, the doctype would be applied from this XSL, but it's currently in a separate XSL
       under themes/Archie-Mirage
       
    <xsl:output doctype-public="-//NLM//DTD PubMed 2.0//EN" doctype-system="http://www.ncbi.nlm.nih.gov:80/entrez/query/static/PubMed.dtd" indent="yes"/>
 	  
    <xsl:template match="/">
    	
    Ideally, the root ArticleSet element would be applied here, but it's set in the DSpaceNLMGenerator instead.
    
      <xsl:element name="ArticleSet">
    	<xsl:apply-templates select="*[@dspaceType='ITEM' and dspace:field[@element ='type']='Article']"/>
      </xsl:element>     
    </xsl:template>
-->       
	<xsl:template match="*[@dspaceType='ITEM' and dspace:field[@element ='type']='Article']">
			<xsl:variable name="handle">
				<xsl:value-of select="concat('hdl:',substring-after(dspace:field[@element ='identifier' and @qualifier='uri'],'http://hdl.handle.net/'))"/>
			</xsl:variable>
		<xsl:element name="Article">
		<!-- Apply Journal data templates -->		
			<xsl:element name="Journal">
				<xsl:apply-templates select="dspace:field[@element='publisher']" mode="journalFields"/>
				<xsl:apply-templates select="dspace:field[@element='ispartof'" mode="journalFields"/>
				<xsl:apply-templates select="dspace:field[@element='date' and @qualifier='available']" mode="journalFields"/>
			</xsl:element>
	    <!-- Apply Article data templates -->
			<xsl:apply-templates select="dspace:field[@element ='title']"/>
			<xsl:apply-templates select="dspace:field[@element='spage']"/>
        	<xsl:apply-templates select="dspace:field[@element ='identifier' and @qualifier='uri']" mode="elocId">
				<xsl:with-param name="hdl" select="$handle"/>
			</xsl:apply-templates>						
			<xsl:element name="AuthorList">
				<xsl:apply-templates select="dspace:field[@element ='contributor' and @qualifier='author']"/>
			</xsl:element>
			<xsl:element name="ArticleIdList">
				<xsl:apply-templates select="dspace:field[@element ='identifier' and @qualifier='uri']" mode="articleId">
					<xsl:with-param name="hdl" select="$handle"/>
				</xsl:apply-templates>
			</xsl:element>
  			<xsl:apply-templates select="dspace:field[@element='description' and @qualifier='abstract']"/>
		</xsl:element>
	</xsl:template>
	
	<!-- Apply Publisher data templates -->
	<xsl:template match="dspace:field[@element='publisher']" mode="journalFields">
		<xsl:element name="PublisherName">
			<xsl:value-of select="text()"/>
		</xsl:element>
	</xsl:template>
	
	<!-- Get Journal Title, Issn, Volume, and Issue from Relation:isPartOf -->
	<xsl:template match="dspace:field[@element='ispartof']" mode="journalFields">
		<xsl:choose>
			<xsl:when test="[@qualifier='issn']">
				<xsl:element name="Issn">
					<xsl:value-of select="text()"/>
				</xsl:element>
			</xsl:when>
			<xsl:when test="[@qualifier='volume']">
				<xsl:element name="Volume">
					<xsl:value-of select="text()"/>
				</xsl:element>
			</xsl:when>
			<xsl:when test="[@qualifier='issue']">
				<xsl:element name="Issue">
					<xsl:value-of select="text()"/>
				</xsl:element>
			</xsl:when>
			<xsl:when test="[@qualifier='title']">
				<xsl:element name="JournalTitle">
					<xsl:value-of select="text()"/>
				</xsl:element>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<!-- PubDate -->
	<xsl:template match="dspace:field[@element='date' and @qualifier='available']" mode="journalFields">
		<xsl:element name="PubDate">
			<xsl:attribute name="PubStatus">
				<xsl:text>epublish</xsl:text>
			</xsl:attribute>
			<xsl:element name="Year">
				<xsl:value-of select="substring-before(text(),'-')"/>
			</xsl:element>
			<xsl:variable name="date_rightOf_year">
				<xsl:value-of select="substring-after(text(),'-')"/>
			</xsl:variable>
			<xsl:element name="Month">
				<xsl:value-of select="substring-before($date_rightOf_year,'-')"/>
			</xsl:element>
			<xsl:element name="Day">
				<xsl:variable name="date_rightOf_month">
					<xsl:value-of select="substring-after($date_rightOf_year,'-')"/>
				</xsl:variable>
				<xsl:value-of select="substring-before($date_rightOf_month,'T')"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
	<!-- Article Data -->
	<xsl:template match="dspace:field[@element ='title']">
		<xsl:element name="ArticleTitle">
			<xsl:value-of select="text()"/>
		</xsl:element>
	</xsl:template>
	<xsl:template match="dspace:field[@element ='contributor' and @qualifier='author']">
		<xsl:element name="Author">
			<xsl:variable name="givenname" select="normalize-space(substring-after(text(),','))"/>
			<xsl:variable name="firstname" select="substring-before($givenname,' ')"/>
			<xsl:choose>
			<xsl:when test="$firstname">
				<xsl:element name="FirstName">
					<xsl:value-of select="$firstname"/>
				</xsl:element>
				<xsl:element name="MiddleName">
					<xsl:value-of select="substring-after($givenname,' ')"/>
				</xsl:element>
			</xsl:when>
		    <xsl:otherwise>
					<xsl:element name="FirstName">
						<xsl:value-of select="$givenname"/>
					</xsl:element>
			</xsl:otherwise>
		    </xsl:choose>
			<xsl:element name="LastName">
				<xsl:value-of select="substring-before(text(),',')"/>
			</xsl:element>
			<xsl:if test="position()=1">
		      <xsl:element name="Affiliation">
		      	<xsl:if test="starts-with(dspace:field[@element='contributor' and @qualifier='organization'],'Institution:')"
				  <xsl:value-of select="translate(substring-after(../dspace:field[@element='contributor' and @qualifier='organization'],'Institution:'),':',',')"/>
		        <xsl:otherwise>
		        	<xsl:value-of select="../dspace:field[@element='contributor' and @qualifier='organization']"/>
		        </xsl:otherwise>
		        </xsl:if>
		      </xsl:element>			    
			</xsl:if>		    
		</xsl:element>
	</xsl:template>
	<xsl:template match="dspace:field[@element='identifier' and @qualifier='uri']" mode="articleId">
		<xsl:param name="hdl"/>
		<xsl:element name="ArticleId">
			<xsl:attribute name="IdType">pii</xsl:attribute>
			<xsl:value-of select="$hdl"/>
		</xsl:element>
	</xsl:template>
	<xsl:template match="dspace:field[@element='identifier' and @qualifier='uri']" mode="elocId">
		<xsl:param name="hdl"/>
		<xsl:element name="ELocationID">
			<xsl:attribute name="EIdType">pii</xsl:attribute>
			<xsl:value-of select="$hdl"/>
		</xsl:element>
	</xsl:template>
	<xsl:template match="dspace:field[@element='description' and @qualifier='abstract']">
		<xsl:element name="Abstract">
			<xsl:value-of select="text()"/>
		</xsl:element>
	</xsl:template>
	<xsl:template match="dspace:field[@element='spage']">
		<xsl:element name="FirstPage">
			<xsl:value-of select="concat('E',text())"/>
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>