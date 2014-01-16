<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:css="http://www.w3.org/1996/css"
  xmlns:dbk="http://docbook.org/ns/docbook"
  xmlns:hub="http://www.le-tex.de/namespace/hub"
  xmlns:hub2tei="http://www.le-tex.de/namespace/hub2tei"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:cx="http://xmlcalabash.com/ns/extensions" 
  xmlns="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="dbk hub2tei hub xlink css xs cx"
  version="2.0">

  <!-- see also docbook to tei:
       http://svn.le-tex.de/svn/ltxbase/DBK2TEI -->

  <xsl:param name="debug" select="'no'" as="xs:string?"/>
  <xsl:param name="debug-dir-uri" select="'debug'" as="xs:string"/>

  <xsl:output method="xml"/>

  <xsl:output name="debug" method="xml" indent="yes"/>

  <xsl:template match="* | @* | processing-instruction()" mode="hub2tei:dbk2tei hub2tei:tidy" priority="-1">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <!-- Processing pipeline: -->

  <xsl:variable name="hub2tei:dbk2tei">
    <xsl:apply-templates select="/" mode="hub2tei:dbk2tei"/>
  </xsl:variable>

  <xsl:variable name="hub2tei:tidy">
    <xsl:apply-templates select="$hub2tei:dbk2tei" mode="hub2tei:tidy"/>
  </xsl:variable>

  <xsl:template name="main">
    <xsl:if test="$debug = 'yes'">
      <xsl:call-template name="debug-hub2tei"/>
    </xsl:if>
    <xsl:sequence select="$hub2tei:tidy"/>
  </xsl:template>

  <xsl:template name="debug-hub2tei">
    <xsl:result-document href="{resolve-uri(concat($debug-dir-uri, '/40.dbk2tei.xml'))}" format="debug">
      <xsl:sequence select="$hub2tei:dbk2tei"/>
    </xsl:result-document>
    <xsl:result-document href="{resolve-uri(concat($debug-dir-uri, '/99.tidy.xml'))}" format="debug">
      <xsl:sequence select="$hub2tei:tidy"/>
    </xsl:result-document>
  </xsl:template>

  <xsl:template match="/*/@xml:base" mode="hub2tei:dbk2tei">
    <xsl:attribute name="xml:base" select="replace(., '\.hub\.xml$', '.tei.xml')"/>
  </xsl:template>

  <xsl:template match="/dbk:*" mode="hub2tei:dbk2tei">
    <TEI>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:attribute name="source-dir-uri" select="dbk:info/dbk:keywordset[@role eq 'hub']/dbk:keyword[@role eq 'source-dir-uri']"/>      
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
        <profileDesc>
          <xsl:apply-templates select="dbk:info/dbk:keywordset[@role = 'hub']" mode="#current"/>
          <langUsage>
            <language>
              <xsl:attribute name="ident">
                <xsl:apply-templates select="/dbk:*/@xml:lang" mode="#current"/>
              </xsl:attribute>
            </language>
          </langUsage>            
        </profileDesc>
        <encodingDesc>
          <styleDefDecl scheme="cssa"/>
          <xsl:apply-templates select="/*/dbk:info/css:rules" mode="#current"></xsl:apply-templates>
        </encodingDesc>
      </teiHeader>
      <text>
        <xsl:apply-templates select="dbk:info" mode="#current"/>
        <body>
          <xsl:apply-templates select="* except dbk:info" mode="#current"/>
        </body>
      </text>
    </TEI>
  </xsl:template>
  
  <xsl:template match="dbk:info" mode="hub2tei:dbk2tei">
    <front>
      <xsl:apply-templates select="* except (dbk:keywordset | css:rules)" mode="#current"/>
    </front>
  </xsl:template>
  
  <xsl:template match="dbk:info/dbk:keywordset[@role = 'hub']" mode="hub2tei:dbk2tei">
      <textClass>
        <keywords scheme="http://www.le-tex.de/resource/schema/hub/1.1/hub.rng">
          <xsl:apply-templates mode="#current"/>
        </keywords>
      </textClass>
  </xsl:template>
  
  <xsl:template match="dbk:keyword" mode="hub2tei:dbk2tei">
    <term key="{@role}">
        <xsl:apply-templates mode="#current"/>
    </term>
  </xsl:template>
  
  <xsl:template match="/dbk:book/dbk:info/dbk:legalnotice" mode="hub2tei:dbk2tei">
    <div type="imprint">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </div>
  </xsl:template>

  <xsl:template match="dbk:dedication" mode="hub2tei:dbk2tei">
    <div type="dedication">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </div>
  </xsl:template>
  
  <xsl:template match="processing-instruction('xml-model')" mode="hub2tei:dbk2tei"/>

  <xsl:template match="@css:rule-selection-attribute" mode="hub2tei:dbk2tei">
    <xsl:attribute name="{name()}" select="'rend'"/>
  </xsl:template>
  
  <xsl:template match="@xml:id" mode="hub2tei:dbk2tei">
    <xsl:copy/>
  </xsl:template>

  <!-- (mis)used to convey original InDesign text anchor IDs in dbk:anchor. 
        We need to further convey this because it will form the key for
        a crossref query, enabling the crossref results to be patched into
        the InDesign source. -->
  <xsl:template match="dbk:anchor/@annotations" mode="hub2tei:dbk2tei">
    <xsl:attribute name="n" select="."/>
  </xsl:template>
  
  <xsl:template match="dbk:part | dbk:chapter | dbk:section | dbk:appendix" mode="hub2tei:dbk2tei">
    <div type="{name()}">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </div>
  </xsl:template>

  <xsl:template match="dbk:title" mode="hub2tei:dbk2tei">
    <head>
      <xsl:apply-templates select="@* except @role, node()" mode="#current"/>
    </head>
  </xsl:template>

  <xsl:template match="dbk:para" mode="hub2tei:dbk2tei">
    <p>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </p>
  </xsl:template>

  <xsl:template match="dbk:anchor" mode="hub2tei:dbk2tei">
    <anchor>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </anchor>
  </xsl:template>

  <xsl:template match="dbk:link" mode="hub2tei:dbk2tei">
    <xsl:element name="{if(
                         matches(
                           (@linkend, @xlink:href)[1], 
                           '^(file|http|ftp)[:]//.+'
                         )
                        ) 
                        then 'ref' else 'link'}">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="@xlink:href | dbk:link/@linkend" mode="hub2tei:dbk2tei">
    <xsl:attribute name="target" select="."/>
  </xsl:template>

  <xsl:template match="dbk:footnote" mode="hub2tei:dbk2tei">
    <note type="footnote">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </note>
  </xsl:template>

  <xsl:template match="dbk:br" mode="hub2tei:dbk2tei">
    <lb/>
  </xsl:template>

  <xsl:template match="dbk:tab" mode="hub2tei:dbk2tei">
    <seg type="{if(@role) then @role else 'tab'}">
      <xsl:apply-templates mode="#current"/>
    </seg>
  </xsl:template>

  <xsl:template match="css:rule//*" mode="hub2tei:dbk2tei">
    <xsl:copy-of select="."/>
  </xsl:template>
  

  <xsl:template match="dbk:phrase" mode="hub2tei:dbk2tei">
    <seg>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </seg>
  </xsl:template>

  <xsl:template match="dbk:superscript | dbk:subscript" mode="hub2tei:dbk2tei">
    <hi rend="{local-name()}">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </hi>
  </xsl:template>
  
  <!-- @type is no longer supported for each element in TEI P5  -->
  <xsl:template match="@role" mode="hub2tei:dbk2tei">
    <xsl:attribute name="rend" select="."/>
  </xsl:template>
  
  <!-- handle page breaks -->
  <xsl:template match="*[@css:page-break-before or @css:page-break-after]" mode="hub2tei:dbk2tei" priority="10">
    <xsl:choose>
      <xsl:when test="(@css:page-break-before|@css:page-break-after) = ('always', 'left', 'right')">
        <xsl:choose>
          <xsl:when test=". eq ''">
            <pb/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:if test="@css:page-break-before">
              <pb/>
            </xsl:if>
            <xsl:next-match/>
            <xsl:if test="@css:page-break-after">
              <pb/>
            </xsl:if>  
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:next-match/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="@css:page-break-after|@css:page-break-before" mode="hub2tei:dbk2tei"/>

  <xsl:template match="dbk:phrase[@role eq 'footnote_reference'][dbk:footnote][count(node()) eq 1]" mode="hub2tei:dbk2tei">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>

  <xsl:template match="dbk:blockquote" mode="hub2tei:dbk2tei">
    <quote>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </quote>
  </xsl:template>

  <xsl:template match="dbk:itemizedlist|dbk:orderedlist|dbk:variablelist" mode="hub2tei:dbk2tei">
    <list rend="{local-name()}">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </list>
  </xsl:template>

  <xsl:variable name="poem-style-regex" select="'((g|G)edicht)'"  as="xs:string"/>
  <xsl:template match="dbk:para[matches(@role, $poem-style-regex)]" mode="hub2tei:dbk2tei">
    <l>
      <xsl:apply-templates select="@*" mode="hub2tei:dbk2tei"/>
      <xsl:apply-templates select="node()" mode="#current"/>
    </l>
  </xsl:template>
  
  <xsl:template match="dbk:poetry" mode="hub2tei:dbk2tei">
    <lg>
      <xsl:apply-templates select="node()" mode="#current"/>
    </lg>
  </xsl:template>
  
  <xsl:template match="dbk:listitem[not(parent::dbk:varlistentry)]|dbk:varlistentry" mode="hub2tei:dbk2tei">
    <item rend="{local-name()}">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </item>
  </xsl:template>
  
  <xsl:template match="@override" mode="hub2tei:dbk2tei">
    <xsl:attribute name="n" select="."/>
  </xsl:template>
  
  <xsl:template match="@numeration" mode="hub2tei:dbk2tei">
    <xsl:variable name="numeration-style" select="
      if(. eq 'arabic') then 'decimal' 
      else if(. eq 'loweralpha') then 'lower-latin'
      else if(. eq 'upperalpha') then 'upper-latin'
      else if(. eq 'lowerroman') then 'lower-roman'
      else if(. eq 'upperroman') then 'upper-roman'
      else ''"/>
    <xsl:if test="$numeration-style ne ''">
      <xsl:attribute name="style" select="concat('list-style-type:', $numeration-style ,';')"/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="dbk:listitem[parent::dbk:varlistentry]" mode="hub2tei:dbk2tei">
    <gloss rend="{local-name()}">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </gloss>
  </xsl:template>
  
  <xsl:template match="dbk:term" mode="hub2tei:dbk2tei">
    <term rend="{local-name()}">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </term>
  </xsl:template>
  
  <xsl:template match="dbk:tabs|dbk:seg" mode="hub2tei:dbk2tei">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <xsl:template match="figure" mode="hub2tei:dbk2tei" 
    xpath-default-namespace="http://docbook.org/ns/docbook">
    <figure>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </figure>
  </xsl:template>
 
  <xsl:template match="mediaobject[imageobject/imagedata/@fileref] | inlinemediaobject[imageobject/imagedata/@fileref]" mode="hub2tei:dbk2tei" 
    xpath-default-namespace="http://docbook.org/ns/docbook">
      <graphic url="{imageobject/imagedata/@fileref}">
        <xsl:if test="imageobject/imagedata/@width">
          <xsl:attribute name="width" select="if (matches(imageobject/imagedata/@width,'^\.')) then replace(imageobject/imagedata/@width,'^\.','0.') else imageobject/imagedata/@width"/>
        </xsl:if>
        <xsl:if test="imageobject/imagedata/@depth">
          <xsl:attribute name="height" select="if (matches(imageobject/imagedata/@depth,'[0-9]$')) then string-join((imageobject/imagedata/@depth,'pt'),'') else imageobject/imagedata/@depth"/>
        </xsl:if>
        <xsl:if test="./@role">
          <xsl:attribute name="rend" select="@role"/>
        </xsl:if>
      </graphic>
  </xsl:template>
  
  <xsl:variable name="caption-style-regex" select="'legend'" as="xs:string"/>
  
  <xsl:template match="para[matches(@role, $caption-style-regex)]" mode="hub2tei:dbk2tei" xpath-default-namespace="http://docbook.org/ns/docbook">
    <caption>
      <xsl:apply-templates select="@*, node()" mode="hub2tei:dbk2tei"/>
    </caption>
  </xsl:template>
  
  <xsl:template match="note[matches(para/@role, $caption-style-regex)]" mode="hub2tei:dbk2tei" xpath-default-namespace="http://docbook.org/ns/docbook">
      <xsl:apply-templates select="node()" mode="hub2tei:dbk2tei"/>
  </xsl:template>

  <xsl:template match="informaltable | table" mode="hub2tei:dbk2tei"
    xpath-default-namespace="http://docbook.org/ns/docbook"
    >
    <table>
      <xsl:apply-templates select="@xml:id | @role" mode="#current"/>
      <xsl:choose>
        <xsl:when test="exists(tgroup)">
          <xsl:for-each select="./tgroup/(tbody union thead union tfoot)/row">
            <tr>
              <xsl:for-each select="entry">
                <td>
                  <xsl:if test="@namest">
                    <xsl:attribute name="colspan" select="number(substring-after(@nameend, 'col')) - number(substring-after(@namest, 'col')) + 1"/>
                  </xsl:if>
                  <xsl:if test="@morerows &gt; 0">
                    <xsl:attribute name="rowspan" select="@morerows + 1"/>
                  </xsl:if>
                  <xsl:apply-templates select="@css:*" mode="#current"/>
                  <xsl:apply-templates mode="#current"/>
                </td>
              </xsl:for-each>
            </tr>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <tr>
            <td>
              <xsl:apply-templates mode="#current"/>
            </td>
          </tr>
        </xsl:otherwise>
      </xsl:choose>
    </table>
  </xsl:template>
  
  <!-- use templates from hub2html for style serializing. Thanks to the TEI+CSSa
    schema, we don’t need to prematurely serialize CSS here -->
  <xsl:template match="tei:*[@css:*]" mode="hub2tei:tidy_DISABLED">
    <xsl:copy>
      <xsl:attribute name="style" select="string-join(for $i in @css:* return concat($i/local-name(), ':', $i), ';')"/>
      <xsl:apply-templates select="@* except @css:*, node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="tei:seg[not(@*)]" mode="hub2tei:tidy">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>

  <xsl:template match="tei:table[not(@type)]" mode="hub2tei:tidy">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:attribute name="type" select="'other'"/>
      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="/*" mode="hub2tei:tidy" priority="2">
    <xsl:copy>
      <xsl:namespace name="css" select="'http://www.w3.org/1996/css'"/>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>
