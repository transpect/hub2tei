<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:css="http://www.w3.org/1996/css"
  xmlns:dbk="http://docbook.org/ns/docbook"
  xmlns:hub="http://www.le-tex.de/namespace/hub"
  xmlns:hub2tei="http://www.le-tex.de/namespace/hub2tei"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:edu="http://www.le-tex.de/namespace/edu"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  exclude-result-prefixes="dbk xs"
  version="2.0">

  <!-- see also docbook to tei:
       http://svn.le-tex.de/svn/ltxbase/DBK2TEI -->

  <xsl:param name="debug" select="'no'" as="xs:string?"/>
  <xsl:param name="debug-dir-uri" select="'debug'" as="xs:string"/>


  <xsl:output method="xml"/>

  <xsl:output name="debug" method="xml" indent="yes"/>


  <xsl:template match="* | @* | processing-instruction()" 
    mode="insert-sep
          dbk2tei
          preprocess-hub
          join-emph
          join-emph-unwrap
          tabbed-lists
          inline-lists
          inline-lists-insert-sep
          inline-lists-slice
          inline-lists-dissolve-empty-phrases
          group-other-sections
          edu
          tidy" priority="-1">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*, node()" mode="#current" />
    </xsl:copy>
  </xsl:template>

  <!-- Processing pipeline: -->

  <xsl:variable name="hub2tei:dbk2tei">
    <xsl:apply-templates select="/" mode="hub2tei:dbk2tei" />
  </xsl:variable>

  <xsl:variable name="hub2tei:tidy">
    <xsl:apply-templates select="$hub2tei:dbk2tei" mode="hub2tei:tidy" />
  </xsl:variable>

  <xsl:template name="main">
    <xsl:if test="$debug = 'yes'">
      <xsl:call-template name="debug-hub2tei" />
    </xsl:if>
    <xsl:sequence select="$hub2tei:tidy" />
  </xsl:template>

  <xsl:template name="debug-hub2tei">
    <xsl:result-document href="{resolve-uri(concat($debug-dir-uri, '/40.dbk2tei.xml'))}" format="debug">
      <xsl:sequence select="$hub2tei:dbk2tei" />
    </xsl:result-document>
    <xsl:result-document href="{resolve-uri(concat($debug-dir-uri, '/99.tidy.xml'))}" format="debug">
      <xsl:sequence select="$hub2tei:tidy" />
    </xsl:result-document>
  </xsl:template>


  <xsl:template match="/*/@xml:base" mode="hub2tei:dbk2tei">
    <xsl:attribute name="xml:base" select="replace(., '\.hub\.xml$', '.tei.xml')" />
  </xsl:template>

  <xsl:template match="/dbk:*" mode="hub2tei:dbk2tei" xmlns="http://www.tei-c.org/ns/1.0">
    <TEI xml:lang="de">
      <xsl:apply-templates select="@xml:base" mode="#current" />
      <teiHeader>
        <fileDesc>
          <titleStmt>
            <title/>
            <author/>
          </titleStmt>
          <publicationStmt>
            <distributor>
              <address>
                <addrLine>
                  <name type="organisation"/>
                </addrLine>
                <addrLine>
                  <name type="place"/>
                </addrLine>
              </address>
            </distributor>
            <idno type="book"/>
            <date/>
            <pubPlace/>
            <publisher/>
          </publicationStmt>
          <sourceDesc>
            <p/>
          </sourceDesc>
        </fileDesc>
      </teiHeader>
      <text>
        <body>
          <xsl:apply-templates select="* except dbk:info" mode="#current" />
        </body>
      </text>
    </TEI>
  </xsl:template>

  <xsl:template match="processing-instruction('xml-model')" mode="hub2tei:dbk2tei" />

  <xsl:template match="dbk:section" mode="hub2tei:dbk2tei" xmlns="http://www.tei-c.org/ns/1.0">
    <div>
      <xsl:apply-templates select="dbk:title/@role, @*, node()" mode="#current" />
    </div>
  </xsl:template>

  <xsl:template match="dbk:title"
    mode="hub2tei:dbk2tei" xmlns="http://www.tei-c.org/ns/1.0">
    <head>
      <xsl:apply-templates select="@* except @role, node()" mode="#current" />
    </head>
  </xsl:template>

  <xsl:template match="dbk:para" mode="hub2tei:dbk2tei" xmlns="http://www.tei-c.org/ns/1.0">
    <p>
      <xsl:apply-templates select="@*, node()" mode="#current" />
    </p>
  </xsl:template>

  <xsl:template match="dbk:link" mode="hub2tei:dbk2tei" xmlns="http://www.tei-c.org/ns/1.0">
    <link>
      <xsl:apply-templates select="@*, node()" mode="#current" />
    </link>
  </xsl:template>

  <xsl:template match="@xlink:href" mode="hub2tei:dbk2tei">
    <xsl:attribute name="target" select="." />
  </xsl:template>

  <xsl:template match="dbk:footnote" mode="hub2tei:dbk2tei" xmlns="http://www.tei-c.org/ns/1.0">
    <note type="footnote">
      <xsl:apply-templates select="@*, node()" mode="#current" />
    </note>
  </xsl:template>

  <xsl:template match="dbk:br" mode="hub2tei:dbk2tei" xmlns="http://www.tei-c.org/ns/1.0">
    <seg type="br" />
  </xsl:template>

  <xsl:template match="dbk:tab" mode="hub2tei:dbk2tei" xmlns="http://www.tei-c.org/ns/1.0">
    <seg type="{if(@role) then @role else 'tab'}">
      <xsl:apply-templates mode="#current"/>
    </seg>
  </xsl:template>

  <xsl:template match="dbk:phrase" mode="hub2tei:dbk2tei" xmlns="http://www.tei-c.org/ns/1.0">
    <seg>
      <xsl:apply-templates select="@*, node()" mode="#current" />
    </seg>
  </xsl:template>

  <xsl:template match="dbk:phrase[@css:font-style eq 'italic']" mode="hub2tei:dbk2tei" xmlns="http://www.tei-c.org/ns/1.0">
    <foreign xml:lang="en">
      <xsl:apply-templates select="@* except @css:font-style, node()" mode="#current" />
    </foreign>
  </xsl:template>

  <xsl:template match="@role" mode="hub2tei:dbk2tei">
    <xsl:attribute name="type" select="." />
  </xsl:template>

  <xsl:template match="dbk:phrase[@role eq 'footnote_reference'][dbk:footnote][count(node()) eq 1]" mode="hub2tei:dbk2tei">
    <xsl:apply-templates mode="#current" />
  </xsl:template>

  <xsl:template match="dbk:itemizedlist" mode="hub2tei:dbk2tei" xmlns="http://www.tei-c.org/ns/1.0">
    <list>
      <xsl:apply-templates select="@*, node()" mode="#current" />
    </list>
  </xsl:template>

  <xsl:template match="dbk:item" mode="hub2tei:dbk2tei" xmlns="http://www.tei-c.org/ns/1.0">
    <xsl:element name="{local-name()}">
      <xsl:apply-templates select="@*, node()" mode="#current" />
    </xsl:element>
  </xsl:template>

  <xsl:template match="mediaobject[imageobject/imagedata/@fileref]" mode="hub2tei:dbk2tei" 
    xpath-default-namespace="http://docbook.org/ns/docbook" xmlns="http://www.tei-c.org/ns/1.0">
    <graphic url="{imageobject/imagedata/@fileref}">
      <xsl:if test="imageobject/imagedata/@width">
        <xsl:attribute name="width" select="if (matches(imageobject/imagedata/@width,'^\.')) then replace(imageobject/imagedata/@width,'^\.','0.') else imageobject/imagedata/@width"/>
      </xsl:if>
      <xsl:if test="imageobject/imagedata/@depth">
        <xsl:attribute name="height" select="if (matches(imageobject/imagedata/@depth,'[0-9]$')) then string-join((imageobject/imagedata/@depth,'pt'),'') else imageobject/imagedata/@depth"/>
      </xsl:if>
    </graphic>
  </xsl:template>

  <xsl:template match="informaltable | table" mode="hub2tei:dbk2tei"
    xpath-default-namespace="http://docbook.org/ns/docbook"
    xmlns="http://www.tei-c.org/ns/1.0">
    <table>
      <xsl:apply-templates select="@xml:id | @role" mode="#current" />
      <xsl:choose>
        <xsl:when test="exists(tgroup)">
          <xsl:for-each select="./tgroup/(tbody union thead union tfoot)/row">
            <tr>
              <xsl:for-each select="entry">
                <td>
                  <xsl:if test="@namest">
                    <xsl:attribute name="colspan" select="number(substring-after(@nameend, 'col')) - number(substring-after(@namest, 'col')) + 1" />
                  </xsl:if>
                  <xsl:if test="@morerows &gt; 0">
                    <xsl:attribute name="rowspan" select="@morerows + 1" />
                  </xsl:if>
                  <xsl:apply-templates select="@css:*" mode="#current"/>
                  <xsl:apply-templates mode="#current" />
                </td>
              </xsl:for-each>
            </tr>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <tr>
            <td>
              <xsl:apply-templates mode="#current" />
            </td>
          </tr>
        </xsl:otherwise>
      </xsl:choose>
    </table>
  </xsl:template>

  <xsl:template match="tei:seg[not(@*)]" mode="hub2tei:tidy">
    <xsl:apply-templates mode="#current" />
  </xsl:template>

  <xsl:template match="tei:table[not(@type)]" mode="hub2tei:tidy">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*" mode="#current" />
      <xsl:attribute name="type" select="'other'" />
      <xsl:apply-templates mode="#current" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="/*" mode="hub2tei:tidy">
    <xsl:processing-instruction name="xml-model">href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"</xsl:processing-instruction>
    <xsl:processing-instruction name="xml-model">href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"</xsl:processing-instruction>
    <xsl:copy>
      <xsl:namespace name="edu" select="'http://www.le-tex.de/namespace/edu'" />
      <xsl:namespace name="css" select="'http://www.w3.org/1996/css'" />
      <xsl:apply-templates select="@*, node()" mode="#current" />
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>