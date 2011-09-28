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
	<!-- Get Journal Title, ISSN, Volume, and Issue from Relation:isPartOf -->
	<!-- PubDate -->
	<!-- Article details -->
	<!-- Only match "ITEM" nodes that have dc.type=Article. This omits Tables of Contents items from output
     since they have a different dc.type.
-->
<!--     <xsl:output doctype-public="-//NLM//DTD PubMed 2.0//EN" doctype-system="http://www.ncbi.nlm.nih.gov:80/entrez/query/static/PubMed.dtd" indent="yes"/>
 	  
    <xsl:template match="/">
      <xsl:element name="ArticleSet">
    	<xsl:apply-templates select="*[@dspaceType='ITEM' and dspace:field[@element ='type']='Article']"/>
      </xsl:element>     
    </xsl:template>
-->    
	<xsl:template match="*[@dspaceType='ITEM' and dspace:field[@element ='type']='Article']">
		<xsl:element name="Article">
			<xsl:element name="Journal">
				<xsl:apply-templates select="dspace:field[@element='publisher']" mode="journalFields"/>
				<xsl:apply-templates select="dspace:field[@element='relation' and @qualifier='ispartof']" mode="journalFields"/>
				<xsl:apply-templates select="dspace:field[@element='date' and @qualifier='available']" mode="journalFields"/>
			</xsl:element>
			<xsl:apply-templates select="dspace:field[@element ='title']"/>
			<xsl:element name="AuthorList">
				<xsl:apply-templates select="dspace:field[@element ='contributor' and @qualifier='author']"/>
			</xsl:element>
			<xsl:variable name="handle">
				<xsl:value-of select="concat('hdl:',substring-after(dspace:field[@element ='identifier' and @qualifier='uri'],'http://hdl.handle.net/'))"/>
			</xsl:variable>
			<xsl:element name="ArticleIdList">
				<xsl:apply-templates select="dspace:field[@element ='identifier' and @qualifier='uri']" mode="articleId">
					<xsl:with-param name="hdl" select="$handle"/>
				</xsl:apply-templates>
			</xsl:element>
        	<xsl:apply-templates select="dspace:field[@element ='identifier' and @qualifier='uri']" mode="elocId">
				<xsl:with-param name="hdl" select="$handle"/>
			</xsl:apply-templates>
  			<xsl:apply-templates select="dspace:field[@element='description' and @qualifier='abstract']"/>
			<xsl:apply-templates select="dspace:field[@element='spage']"/>
		</xsl:element>
	</xsl:template>
	<!-- Journal Data -->
	<!-- Publisher -->
	<xsl:template match="dspace:field[@element='publisher']" mode="journalFields">
		<xsl:element name="PublisherName">
			<xsl:value-of select="text()"/>
		</xsl:element>
	</xsl:template>
	<!-- Get Journal Title, ISSN, Volume, and Issue from Relation:isPartOf -->
	<xsl:template match="dspace:field[@element='relation' and @qualifier='ispartof']" mode="journalFields">
		<xsl:choose>
			<xsl:when test="starts-with(., 'urn:ISSN:')">
				<xsl:element name="ISSN">
					<xsl:value-of select="substring-after(text(),'urn:ISSN:')"/>
				</xsl:element>
			</xsl:when>
			<xsl:when test="number(translate(.,'-',''))">
				<!--Remove any hyphen and test whether it's numeric by comparing to "Not a Number"-->
				<xsl:element name="ISSN">
					<xsl:value-of select="text()"/>
				</xsl:element>
			</xsl:when>
			<xsl:when test="starts-with(., 'volume:')">
				<xsl:element name="Volume">
					<xsl:value-of select="substring-after(text(),'volume:')"/>
				</xsl:element>
			</xsl:when>
			<xsl:when test="starts-with(., 'issue:')">
				<xsl:element name="Issue">
					<xsl:value-of select="substring-after(text(),'issue:')"/>
				</xsl:element>
			</xsl:when>
			<xsl:otherwise>
				<xsl:element name="JournalTitle">
					<xsl:value-of select="text()"/>
				</xsl:element>
			</xsl:otherwise>
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
		</xsl:element>
	</xsl:template>
	<xsl:template match="dspace:field[@element='identifier' and @qualifier='uri']" mode="articleId">
		<xsl:param name="hdl"/>
		<xsl:element name="ArticleId">
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