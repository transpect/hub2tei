<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema" 
                xmlns:css="http://www.w3.org/1996/css" 
                xmlns:dbk="http://docbook.org/ns/docbook" 
                xmlns:hub="http://www.le-tex.de/namespace/hub" 
                xmlns:hub2tei="http://www.le-tex.de/namespace/hub2tei" 
                xmlns:tei="http://www.tei-c.org/ns/1.0" 
                xmlns:xlink="http://www.w3.org/1999/xlink" 
                xmlns:cx="http://xmlcalabash.com/ns/extensions" 
                xmlns:html="http://www.w3.org/1999/xhtml" 
                xmlns="http://www.tei-c.org/ns/1.0" 
                exclude-result-prefixes="dbk hub2tei hub xlink css xs cx" 
                version="2.0">

  <!-- see also docbook to tei:
       http://svn.le-tex.de/svn/ltxbase/DBK2TEI -->
  <xsl:import href="http://transpect.le-tex.de/xslt-util/cals2htmltable/cals2htmltables.xsl"/>

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
            <title>
              <xsl:value-of select="dbk:info/dbk:keywordset[@role eq 'hub']/dbk:keyword[@role eq 'source-basename']"/>
            </title>
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
          <xsl:apply-templates select="/*/dbk:info/css:rules" mode="#current"/>
        </encodingDesc>
      </teiHeader>
      <text>
        <xsl:apply-templates select="dbk:info" mode="#current"/>
        <xsl:variable name="backmatter" as="element(*)*"
          select="(., .[count(dbk:part) = 1]/dbk:part)/(dbk:appendix, dbk:glossary, dbk:bibliography)"/>
        <!-- TO DO: include and respect exclude param in future template that processes dbk:bibliography --> 
        <body>
          <xsl:apply-templates select="* except dbk:info" mode="#current">
            <xsl:with-param name="exclude" select="$backmatter" tunnel="yes"/>
          </xsl:apply-templates>
        </body>
        <xsl:if test="exists($backmatter)">
          <back>
            <xsl:apply-templates select="$backmatter" mode="#current"/>
          </back>
        </xsl:if>
      </text>
    </TEI>
  </xsl:template>

  <xsl:template match="/dbk:book/@xml:lang" mode="hub2tei:dbk2tei">
    <xsl:attribute name="{name(.)}" select="replace(., '^(.+?-.+?)-.*$', '$1')"/>
  </xsl:template>

  <xsl:template match="dbk:info[parent::*[self::dbk:book or self::dbk:hub]]" mode="hub2tei:dbk2tei">
    <xsl:variable name="title-page-parts" select="dbk:authorgroup, dbk:title, dbk:subtitle, dbk:publisher"/>
    <front>
      <xsl:apply-templates select="* except (dbk:keywordset | css:rules | $title-page-parts)" mode="#current"/>
      <titlePage>
        <xsl:apply-templates select="$title-page-parts" mode="#current"/>
      </titlePage>
      <xsl:apply-templates select="//*[local-name() = ('dedication', 'preface', 'colophon', 'toc')]" mode="#current">
        <xsl:with-param name="move-front-matter-parts" select="true()" tunnel="yes"/>
      </xsl:apply-templates>
    </front>
  </xsl:template>

  <!-- creates @rendition attributes from alt images-->
  <xsl:template match="dbk:table | dbk:informaltable" mode="cals2html-table">
    <table>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:if test="exists(*:alt)">
        <xsl:attribute name="rendition" select="*:alt/*:inlinemediaobject/*:imageobject/*:imagedata/@fileref"/>
      </xsl:if>
      <xsl:apply-templates select="node() except (dbk:caption, dbk:info, dbk:note)" mode="#current"/>
    </table>
    <xsl:apply-templates select="dbk:info, dbk:caption, dbk:note" mode="hub2tei:dbk2tei"/>
  </xsl:template>
  
  <xsl:template match="*:table/@rendition[matches(., '^.+?\.(jpe?g|tiff?|png|eps|ai)', 'i')]" mode="hub2tei:dbk2tei" priority="2">
    <xsl:attribute name="{name()}" select="string-join(for $image in tokenize(., ' ') return hub2tei:image-path($image, root(.)), ' ')"/>
  </xsl:template>
  
  <xsl:template match="dbk:info[parent::*[self::dbk:table or self::dbk:figure]][dbk:legalnotice]" mode="hub2tei:dbk2tei">
    <xsl:apply-templates select="node()" mode="#current"/>
  </xsl:template>
  
  <xsl:template match="dbk:info/dbk:legalnotice" mode="hub2tei:dbk2tei">
    <xsl:apply-templates select="node()" mode="#current"/>
  </xsl:template>

  <xsl:template match="dbk:info" mode="hub2tei:dbk2tei">
    <xsl:apply-templates select="node()" mode="#current"/>
  </xsl:template>
  
  <xsl:function name="hub2tei:contains-token" as="xs:boolean">
    <xsl:param name="tokens" as="xs:string"/>
    <xsl:param name="token" as="xs:string?"/>
    <xsl:sequence select="tokenize($tokens, '\s+') = $token"/>
  </xsl:function>
  
  <xsl:function name="hub2tei:rend" as="attribute(rend)?">
    <xsl:param name="role" as="attribute(role)?"/>
    <xsl:param name="except" as="xs:string*"/>
    <xsl:variable name="remaining" select="tokenize($role, '\s+')[not(. = $except)]" as="xs:string*"/>
    <xsl:if test="exists($remaining)">
      <xsl:attribute name="rend" select="$remaining" separator=" "/>
    </xsl:if>
  </xsl:function>

  <xsl:template match="dbk:info/dbk:legalnotice[hub2tei:contains-token(@role, 'copyright')]/*[local-name() = ('para', 'simpara')] " mode="hub2tei:dbk2tei">
    <bibl type="copyright">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </bibl>
  </xsl:template>

  <xsl:template match="dbk:bibliomisc[hub2tei:contains-token(@role, 'source')]" mode="hub2tei:dbk2tei">
    <bibl type="source">
      <xsl:sequence select="hub2tei:rend(@role, 'source')"/>
      <xsl:apply-templates select="@* except @role, node()" mode="#current"/>
    </bibl>
  </xsl:template>

  <xsl:template match="dbk:info/dbk:authorgroup" mode="hub2tei:dbk2tei">
    <xsl:apply-templates select="node()" mode="#current"/>
  </xsl:template>
  
  <xsl:template match="dbk:info[not(parent::*:book)]/dbk:subtitle" priority="4" mode="hub2tei:dbk2tei">
    <head type="sub">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </head>
  </xsl:template>
  
  <xsl:template match="dbk:info[not(local-name(..) = ('book', 'figure'))]/dbk:title" priority="4" mode="hub2tei:dbk2tei">
    <head type="main">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </head>
  </xsl:template>
  
  <xsl:template match="dbk:info/dbk:abstract" mode="hub2tei:dbk2tei">
    <argument>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </argument>
  </xsl:template>
  
  <xsl:template match="dbk:info[parent::dbk:book]/dbk:authorgroup | dbk:partintro" mode="hub2tei:dbk2tei">
    <xsl:apply-templates select="node()" mode="#current"/>
  </xsl:template>


  <xsl:template match="dbk:info/dbk:authorgroup/* | dbk:info/dbk:author" mode="hub2tei:dbk2tei">
    <xsl:element name="{if (../.. is /) then 'docAuthor' else 'byline'}">
      <xsl:apply-templates select="parent::dbk:authorgroup/@*" mode="#current">
        <!-- just in case the authorgroup remaps to a paragraph with @role, @srcpath, etc. -->
      </xsl:apply-templates>
      <xsl:apply-templates select="@*, node()" mode="#current">
        <xsl:with-param name="type" select="local-name()" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:element>
  </xsl:template>

  <xsl:template match="dbk:personname" mode="hub2tei:dbk2tei">
    <xsl:param name="type" as="xs:string?" tunnel="yes"/>
    <persName>
      <xsl:if test="$type">
        <xsl:attribute name="type" select="$type"/>
        <xsl:apply-templates select="@*, node()" mode="#current"/>
      </xsl:if>
    </persName>
  </xsl:template>

  <xsl:template match="dbk:info[parent::dbk:book]/dbk:publisher" mode="hub2tei:dbk2tei">
    <docImprint>
      <publisher>
        <xsl:apply-templates select="@*, .//text()" mode="#current"/>
      </publisher>
    </docImprint>
  </xsl:template>


  <xsl:template match=" *:info[parent::*:book]/*:title | *:info[parent::*:book]/*:subtitle" 
                mode="hub2tei:dbk2tei" priority="5">
    <titlePart>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:attribute name="type" select="if (local-name(.) = 'title') then 'main' else 'sub'"/>
      <xsl:value-of select="normalize-space(.)"/>
    </titlePart>
  </xsl:template>
  
  <xsl:template match="tei:titlePage" mode="hub2tei:tidy">
    <xsl:choose>
      <xsl:when test="not(*)"/>
      <xsl:otherwise>
        <xsl:copy copy-namespaces="no">
          <xsl:apply-templates select="@*" mode="#current"/>
          <xsl:for-each-group select="node()" group-by="local-name()">
            <xsl:choose>
              <xsl:when test="current-grouping-key() = 'titlePart'">
                <docTitle>
                  <xsl:apply-templates select="current-group()" mode="#current"/>
                </docTitle>
              </xsl:when>
              <xsl:otherwise>
                <xsl:apply-templates select="current-group()" mode="#current"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each-group>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="dbk:toc" mode="hub2tei:dbk2tei">
    <xsl:param name="move-front-matter-parts" as="xs:boolean?" tunnel="yes"/>
    <xsl:if test="$move-front-matter-parts">
      <divGen type="toc">
        <xsl:apply-templates select="@*" mode="#current"/>
        <xsl:if test="not(dbk:title) and not(dbk:info[dbk:title])">
          <head>
            <xsl:value-of select="(//info/keywordset/keyword[@role = 'toc-title'], 'Inhalt')[1]"/>
          </head>
        </xsl:if>
        <xsl:apply-templates select="node()" mode="#current"/>
      </divGen>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="tei:divGen[@type = 'toc'][not(ancestor::*[local-name() = 'front'])]" mode="hub2tei:tidy"/>
  
  <xsl:template match="dbk:div[not(matches(@role, $tei:floatingTexts-role))]" mode="hub2tei:dbk2tei">
    <div>
      <xsl:if test="@rend or @type">
        <xsl:attribute name="type">
          <xsl:value-of select="(@type, @rend)[1]"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates select="@* except ((@type, @rend)[1])" mode="#current"/>
      <xsl:apply-templates select="node()" mode="#current"/>
    </div>
  </xsl:template>

  <!-- Equations -->
  
  <xsl:template match="dbk:inlineequation" mode="hub2tei:dbk2tei">
      <xsl:apply-templates select="node()" mode="#current"/>
  </xsl:template>
  
  <xsl:template match="dbk:informalequation" mode="hub2tei:dbk2tei">
    <!--  because formulas are not allowed between paras -->
    <figure>
      <xsl:apply-templates select="node()" mode="#current"/>
    </figure>
  </xsl:template>
  
  <xsl:variable name="hub:equation-counter-style-regex" select="'letex_equation_counter'" as="xs:string"/>
  
  <xsl:template match="dbk:mathphrase" mode="hub2tei:dbk2tei">
    <formula>
      <xsl:apply-templates select="@* except @rend" mode="#current"/>
      <xsl:if test="parent::*[self::dbk:inlineequation]">
        <xsl:attribute name="rend" select="'inline'"/>
      </xsl:if>
      <xsl:if test="dbk:phrase[matches(@role, $hub:equation-counter-style-regex)]">
        <xsl:attribute name="n" select="dbk:phrase[matches(@role, $hub:equation-counter-style-regex)]"/>
      </xsl:if>
      <xsl:apply-templates select="node()" mode="#current"/>
    </formula>
  </xsl:template>
  
  <xsl:template match="@condition" mode="hub2tei:dbk2tei">
    <xsl:attribute name="rendition" select="."/>
  </xsl:template>

  <xsl:template match="@remap[. = 'HiddenText']" mode="hub2tei:dbk2tei"/>

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

  <xsl:template match="dbk:legalnotice" mode="hub2tei:dbk2tei">
    <div type="imprint">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </div>
  </xsl:template>

  <xsl:template match="dbk:dedication | dbk:preface | dbk:colophon" mode="hub2tei:dbk2tei">
    <xsl:param name="move-front-matter-parts" as="xs:boolean?" tunnel="yes"/>
    <xsl:if test="$move-front-matter-parts">
      <div>
        <xsl:attribute name="type" select="name()"/>
        <xsl:if test="./dbk:title[1]/@role">
          <xsl:attribute name="rend" select="./dbk:title[1]/@role"/>
        </xsl:if>
        <xsl:apply-templates select="@*" mode="#current"/>
        <xsl:apply-templates select="*" mode="#current"/>
      </div>
    </xsl:if>
  </xsl:template>


  <xsl:template match="tei:div[@type = 'preface'][count(*) = 2][tei:head][tei:epigraph]" mode="hub2tei:tidy">
    <div type="motto">
      <xsl:apply-templates select="tei:epigraph" mode="#current"/>
    </div>
  </xsl:template>
  
  <xsl:template match="dbk:epigraph" mode="hub2tei:dbk2tei">
    <xsl:choose>
      <xsl:when test="parent::*[self::dbk:preface] or preceding-sibling::*[1][self::dbk:title or self::dbk:info]">
        <epigraph>
          <xsl:apply-templates select="@*, node()" mode="#current"/>
        </epigraph>
      </xsl:when>
      <xsl:otherwise>
        <div type="motto">
          <xsl:apply-templates select="node()" mode="#current"/>
        </div>
      </xsl:otherwise>
    </xsl:choose>
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

  <xsl:template match="dbk:anchor/@xreflabel" mode="hub2tei:dbk2tei"/>

  <xsl:template match="dbk:part | dbk:chapter | dbk:section | dbk:appendix | dbk:acknowledgements | dbk:glossary" mode="hub2tei:dbk2tei">
    <xsl:param name="exclude" tunnel="yes" as="element(*)*"/>
    <xsl:if test="not(some $e in $exclude satisfies (. is $e))">
      <div>
        <xsl:attribute name="type" select="name()"/>
        <xsl:if test="(./dbk:title[1]/@role or ./dbk:info[1]/@role)">
          <xsl:attribute name="rend" select="(./dbk:title[1]/@role, ./dbk:info[1]/@role)[1]"/>
        </xsl:if>
        <xsl:apply-templates select="@*" mode="#current"/>
        <xsl:apply-templates select="*" mode="#current"/>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template match="dbk:index" mode="hub2tei:dbk2tei">
    <xsl:element name="{if (dbk:para) then 'div' else 'divGen'}">
      <xsl:attribute name="type" select="name()"/>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="@renderas" mode="hub2tei:dbk2tei">
    <xsl:attribute name="rend" select="."/>
  </xsl:template>

  <xsl:template match="dbk:title" mode="hub2tei:dbk2tei">
    <head>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </head>
  </xsl:template>
  
  <xsl:template match="dbk:titleabbrev" mode="hub2tei:dbk2tei">
    <!-- Usage: For ToCs or other lists. Not intended to be rendered alongside the title proper -->
    <head type="{local-name()}">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </head>
  </xsl:template>

  <xsl:template match="dbk:caption" mode="hub2tei:dbk2tei">
    <!-- This template was created with figure/caption in mind.
      In TEI, caption-like content is just plain paragraphs within the figure. -->
    <xsl:apply-templates mode="#current"/>
  </xsl:template>

  <xsl:template match="dbk:subtitle" mode="hub2tei:dbk2tei">
    <p>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </p>
  </xsl:template>

  <xsl:template match="dbk:para | dbk:simpara" mode="hub2tei:dbk2tei">
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
    <!--<xsl:element name="{if(
                         matches(
                           (@linkend, @xlink:href)[1], 
                           '^(file|http(s)?|ftp)[:]//.+'
                           ) or 
                           @remap = 'ParagraphDestination'
                        ) 
                        then 'ref' else 'link'}">-->
    <ref>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </ref>
    <!--</xsl:element>-->
  </xsl:template>

  <xsl:template match="dbk:link/@remap" mode="hub2tei:dbk2tei"/>
    
  <xsl:template match="@xlink:href " mode="hub2tei:dbk2tei">
    <xsl:attribute name="target" select="."/>
  </xsl:template>

  <xsl:template match="dbk:link/@linkend" mode="hub2tei:dbk2tei">
    <xsl:attribute name="target" select="concat('#', .)"/>
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

  <xsl:variable name="tei:box-para-style-regex" select="'^letex_boxpara'" as="xs:string"/>
  
  <xsl:function name="hub2tei:conditions-to-dissolve-box-table" as="xs:boolean">
    <xsl:param name="context-table" as="element(dbk:informaltable)"/>
        <xsl:sequence select="if ($context-table[some $r in .//dbk:para/@role satisfies (matches($r, $tei:box-para-style-regex))]) then true() else false()"/>
  </xsl:function>
  
  <!-- This default function dissolves tables thhat have paras with a box-style-role inside -->
  <xsl:template match="dbk:informaltable[hub2tei:conditions-to-dissolve-box-table(.)][not(parent::*[matches(@role, 'Textbox')])]" priority="2" mode="hub2tei:dbk2tei">
    <xsl:variable name="head" select="(.//dbk:para[matches(@role, $tei:box-head1-role-regex)])[1]" as="element(dbk:para)?"/>
    <xsl:variable name="box-symbol" as="element(dbk:imagedata)?" select="$head/parent::*/preceding-sibling::*[1]//dbk:mediaobject/dbk:imageobject/dbk:imagedata"/>
    <floatingText type="box" rend="{@role}">
      <xsl:apply-templates select="($head//dbk:anchor)[1]/@xml:id" mode="#current"/>
      <!--      <xsl:call-template name="box-legend"/>-->
      <body>
        <xsl:if test="(some $a in $head//text() satisfies matches($a, '\S')) or $box-symbol">
          <head>
            <xsl:apply-templates select="$head/@*" mode="#current"/>
            <xsl:if test="$box-symbol">
              <xsl:element name="graphic">
                <xsl:attribute name="url" select="$box-symbol/@fileref"/>
                <xsl:attribute name="id" select="$box-symbol/@xml:id"/>
                <xsl:attribute name="css:width" select="$box-symbol/@css:width"/>
                <xsl:attribute name="css:height" select="$box-symbol/@css:height"/>
              </xsl:element>
            </xsl:if>
            <xsl:apply-templates select="$head/node()" mode="#current"/>
          </head>
        </xsl:if>
        <xsl:apply-templates select=".//dbk:entry/*[not(. is $head) and not(./*[1]/*[1] is $box-symbol)]" mode="#current"/>
        <xsl:apply-templates select=".//dbk:entry/*[. is $box-symbol]" mode="test"/>
      </body>
      <!--      <xsl:apply-templates select="dbk:info[dbk:legalnotice[@role eq 'copyright']]" mode="#current"/>-->
    </floatingText>
  </xsl:template>

  <xsl:template match="dbk:informaltable[hub2tei:conditions-to-dissolve-box-table(.)][parent::*[matches(@role, 'Textbox')]]" priority="2" mode="hub2tei:dbk2tei">
    <xsl:apply-templates select=".//dbk:entry/*" mode="#current"/>
  </xsl:template>
  
  <xsl:template match="*" mode="test"/>

  <xsl:template match="dbk:phrase" mode="hub2tei:dbk2tei">
    <seg>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </seg>
  </xsl:template>

  <xsl:template match="dbk:phrase[@role = 'hub:identifier'] | dbk:label" mode="hub2tei:dbk2tei">
    <label>
      <xsl:apply-templates select="@* except @role, node()" mode="#current"/>
    </label>
  </xsl:template>

  <xsl:template match="dbk:tab[preceding-sibling::*[1][self::dbk:phrase[@role = 'hub:identifier']]]" mode="cals2html-table"/>
  
  <xsl:template match="dbk:superscript | dbk:subscript" mode="hub2tei:dbk2tei">
    <hi rend="{local-name()}">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </hi>
  </xsl:template>

  <xsl:template match="dbk:phrase[key('natives', @role)/@remap = ('superscript', 'subscript')]" mode="hub2tei:dbk2tei">
    <!-- Misuse of @rendition: It is supposed to point somewhere. See http://www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-att.global.rendition.html -->
    <hi rendition="{key('natives', @role)/@remap}">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </hi>
  </xsl:template>
  
  <!-- @type is no longer supported for each element in TEI P5  -->
  <xsl:template match="@role" mode="hub2tei:dbk2tei">
    <xsl:attribute name="rend" select="."/>
  </xsl:template>

  <xsl:key name="natives" match="css:rule" use="@name"/>
  <xsl:variable name="tei:pagebreaks-to-real-pagebreaks" as="xs:boolean" select="true()"/>

  <!-- handle page breaks -->
  <xsl:template match="*[key('natives', @role)/@*[name() =('css:page-break-before', 'css:page-break-after')]][$tei:pagebreaks-to-real-pagebreaks]" mode="hub2tei:dbk2tei" priority="10">
    <xsl:choose>
      <xsl:when test="key('natives', @role)/(@css:page-break-before|@css:page-break-after) = ('always', 'left', 'right')">
        <xsl:choose>
          <xsl:when test=". eq ''">
            <pb/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:if test="key('natives', @role)/@css:page-break-before">
              <pb/>
            </xsl:if>
            <xsl:next-match/>
            <xsl:if test="key('natives', @role)/@css:page-break-after">
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

  <xsl:template match="dbk:footnoteref" mode="hub2tei:dbk2tei">
    <anchor>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </anchor>
  </xsl:template>
  
  <xsl:template match="dbk:footnoteref/@linkend" mode="hub2tei:dbk2tei">
    <xsl:attribute name="xml:id" select="."/>
  </xsl:template>
  
  <xsl:variable name="tei:floatingTexts-role" as="xs:string" select="'^letex_(marginal|box|letter|timetable|code|source)$'"/>
  <xsl:template match="dbk:sidebar[not(matches(@role, $tei:floatingTexts-role))]" mode="hub2tei:dbk2tei">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>

  <xsl:variable name="tei:box-head1-role-regex" select="'^letex_box_heading(_-_.+)?$'" as="xs:string"/>
  <xsl:variable name="tei:box-head2-role-regex" select="'^letex_box_heading2(_-_.+)?$'" as="xs:string"/>

  <xsl:template match="dbk:sidebar[matches(@role, $tei:floatingTexts-role)] | dbk:div[matches(@role, $tei:floatingTexts-role)]" mode="hub2tei:dbk2tei" priority="5">
    <floatingText type="{tei:floatingTexts-type(.)}">
      <xsl:apply-templates select="@*" mode="#current"/>
      <body>
        <xsl:for-each-group select="*" group-starting-with="dbk:para[matches(@role, $tei:box-head1-role-regex)]">
          <xsl:choose>
            <xsl:when test="current-group()[self::dbk:para[matches(@role, $tei:box-head1-role-regex)]]">
              <div1>
                <xsl:for-each-group select="current-group()" group-starting-with="dbk:para[matches(@role, $tei:box-head2-role-regex)]">
                  <xsl:choose>
                    <xsl:when test="current-group()[self::dbk:para[matches(@role, $tei:box-head2-role-regex)]]">
                      <div2>
                        <xsl:apply-templates select="current-group()" mode="#current"/>
                      </div2>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:apply-templates select="current-group()" mode="#current"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:for-each-group>
              </div1>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="current-group()" mode="#current"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each-group>
      </body>
    </floatingText>
  </xsl:template>

  <xsl:template match="dbk:para[matches(@role, $tei:box-head1-role-regex) or matches(@role, $tei:box-head2-role-regex)]" mode="hub2tei:dbk2tei">
    <head>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:apply-templates select="node()" mode="#current"/>
    </head>
  </xsl:template>

  <!-- This function/variables shall be overriden in client-specific templates -->
  <xsl:variable name="tei:box-style-role" select="'^letex_box'" as="xs:string"/>
  <xsl:variable name="tei:marginal-style-role" select="'^letex_marginal'" as="xs:string"/>
  <xsl:function name="tei:floatingTexts-type" as="xs:string">
    <xsl:param name="box" as="element()"/>
    <xsl:variable name="role" select="$box/@role"/>
    <xsl:choose>
      <xsl:when test="matches($role, $tei:box-style-role)">
        <xsl:value-of select="'box'"/>
      </xsl:when>
      <xsl:when test="matches($role,  $tei:marginal-style-role)">
        <xsl:value-of select="'marginal'"/>
      </xsl:when>
      <xsl:otherwise>
        <!-- Only use the base type: -->
        <xsl:value-of select="replace($role, '_-_.*$', '')"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:template match="dbk:blockquote" mode="hub2tei:dbk2tei">
    <quote>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </quote>
  </xsl:template>

  <xsl:template match="dbk:itemizedlist | dbk:orderedlist | dbk:variablelist | dbk:glosslist" mode="hub2tei:dbk2tei">
    <list>
      <xsl:attribute name="type">
        <xsl:choose>
          <xsl:when test="local-name(.) = 'itemizedlist'">
            <xsl:value-of select="'bulleted'"/>
          </xsl:when>
          <xsl:when test="local-name(.) = 'orderedlist'">
            <xsl:value-of select="'ordered'"/>
          </xsl:when>
          <xsl:when test="local-name(.) = ('glosslist', 'variablelist')">
            <xsl:value-of select="'gloss'"/>
          </xsl:when>
        </xsl:choose>
      </xsl:attribute>
      <xsl:if test="ancestor::*[local-name() = 'div'][matches(@role, ('def_flowable|def_table'))]">
        <xsl:attribute name="rend">
          <xsl:value-of select="ancestor::*[local-name() = 'div'][1][matches(@role, ('def_flowable|def_table'))]/@role"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="@mark or @numeration">
        <xsl:attribute name="style" select="(@mark, @numeration)[1]"/>
      </xsl:if>
      <xsl:apply-templates select="@* except (@mark, @numeration)"/>
      <xsl:apply-templates select="node()" mode="#current"/>
    </list>
  </xsl:template>

  <xsl:template match="dbk:listitem[not(parent::dbk:varlistentry)] | dbk:varlistentry | dbk:glossentry" mode="hub2tei:dbk2tei">
    <item rend="{local-name()}">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </item>
  </xsl:template>

  <xsl:template match="dbk:listitem[parent::dbk:varlistentry]/dbk:para | dbk:glossdef | dbk:listitem[parent::dbk:varlistentry][not(dbk:para)]" mode="hub2tei:dbk2tei">
    <gloss rend="{local-name()}">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </gloss>
  </xsl:template>

  <xsl:template match="dbk:listitem[parent::dbk:varlistentry][dbk:para] | dbk:glossdef/dbk:para" mode="hub2tei:dbk2tei">
    <xsl:apply-templates select="node()" mode="#current"/>
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

  <xsl:template match="dbk:term[not(parent::*[1][self::dbk:varlistentry])]" mode="hub2tei:dbk2tei">
    <term rend="{local-name()}">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </term>
  </xsl:template>

  <xsl:template match="dbk:glossterm | dbk:term[parent::*[1][self::dbk:varlistentry]]" mode="hub2tei:dbk2tei">
    <label rend="{local-name()}">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </label>
  </xsl:template>

  <xsl:variable name="hub:poetry-role-regex" select="'letex_poem'" as="xs:string"/>

  <xsl:template match="dbk:para[matches(@role, $hub:poetry-role-regex)]" mode="hub2tei:dbk2tei">
    <xsl:param name="delete-emptyline" tunnel="yes"/>
    <l>
      <xsl:apply-templates select="@* except @role" mode="hub2tei:dbk2tei"/>
      <xsl:attribute name="rend" select="if ($delete-emptyline) then replace(@role, '_-_emptyline(_-_splitter)?', '') else @role"/>
      <xsl:apply-templates select="node()" mode="#current"/>
    </l>
  </xsl:template>

  <xsl:variable name="tei:poem-to-div" as="xs:string" select="'no'"/>

  <xsl:template match="dbk:poetry" mode="hub2tei:dbk2tei">
    <xsl:variable name="poem-content" as="node()*">
      <xsl:variable name="stanzas" as="element(*)*"><!-- tei:lg, but also tei:p for additional text, source, etc. -->
        <xsl:for-each-group select="*" group-adjacent="matches((@role, '')[1], $hub:poetry-role-regex)">
          <xsl:choose>
            <xsl:when test="current-grouping-key()">
              <xsl:for-each-group select="current-group()" group-starting-with="*[hub2tei:is-stanza-start(.)]">
                <lg type="stanza">
                  <xsl:apply-templates select="current-group()" mode="#current">
                    <xsl:with-param name="delete-emptyline" select="true()" as="xs:boolean" tunnel="yes"/>
                  </xsl:apply-templates>
                </lg>
              </xsl:for-each-group>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="current-group()" mode="#current"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each-group>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="count($stanzas) = 1 and $stanzas/self::tei:lg[@type = 'stanza']">
          <xsl:sequence select="$stanzas/node()"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="$stanzas"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$tei:poem-to-div = 'yes'">
        <floatingText type="poetry">
          <body>
            <div>
              <xsl:attribute name="type" select="'poem'"/>
              <xsl:apply-templates select="@*" mode="#current"/>
              <xsl:sequence select="$poem-content"/>
            </div>
          </body>
        </floatingText>
      </xsl:when>
      <xsl:otherwise>
        <lg>
          <xsl:attribute name="type" select="'poem'"/>
          <xsl:apply-templates select="@*" mode="#current"/>
          <xsl:sequence select="$poem-content"/>
        </lg>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

<!--  <xsl:template match="tei:lg | tei:div[@type = 'poetry']" mode="hub2tei:tidy">
    <xsl:copy copy-namespaces="no">
      <xsl:if test="@rend">
        <xsl:attribute name="class" select="@rend"/>
      </xsl:if>
      <xsl:apply-templates select="@* except @rend" mode="#current"/>
      <xsl:for-each-group select="*" group-adjacent="hub2tei:is-stanza(.)">
        <xsl:choose>
          <xsl:when test="current-group()[hub2tei:is-stanza(.)]">
            <lg type="stanza">
              <xsl:apply-templates select="current-group()" mode="#current">
                <xsl:with-param name="delete-emptyline" select="true()" as="xs:boolean" tunnel="yes"/>
              </xsl:apply-templates>
            </lg>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="current-group()" mode="#current"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each-group>
    </xsl:copy>
  </xsl:template>-->

  <xsl:function name="hub2tei:is-stanza-start">
    <xsl:param name="possible-stanza-start"/>
    <xsl:choose>
      <xsl:when test="$possible-stanza-start[self::dbk:para] and matches($possible-stanza-start/@role, 'emptyline(_-_.+)?$')">
        <xsl:sequence select="true()"/>
      </xsl:when>
      <xsl:when test="$possible-stanza-start[self::dbk:para] and
                      (matches($possible-stanza-start/@role, 'poemline(_-_.+)?') and
                              $possible-stanza-start[not(.//text())])">
        <xsl:sequence select="true()"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="false()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:template match="dbk:tabs | dbk:seg" mode="hub2tei:dbk2tei">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>

  <xsl:template match="figure | informalfigure" mode="hub2tei:dbk2tei" xpath-default-namespace="http://docbook.org/ns/docbook">
    <figure>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:apply-templates select="title, titleabbrev" mode="#current"/>
      <xsl:apply-templates select="node() except (title, info)" mode="#current"/>
      <xsl:apply-templates select="info" mode="#current"/>
    </figure>
  </xsl:template>

  <xsl:variable name="hub2tei:drama-style-role-regex" as="xs:string" select="'^letex_Drama'"/>
  <xsl:template match="dbk:para[matches(@role, $hub2tei:drama-style-role-regex)]" mode="hub2tei:dbk2tei" priority="3">
    <sp>
      <xsl:next-match/>
    </sp>
  </xsl:template>

  <xsl:template match="*[tei:sp]" mode="hub2tei:tidy">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:for-each-group select="*" group-adjacent="boolean(self::*:sp)">
        <xsl:choose>
          <xsl:when test="current-group()[self::tei:sp]">
            <spGrp n="{count(current-group())}">
              <xsl:apply-templates select="current-group()" mode="#current"/>
            </spGrp>
          </xsl:when>
          <xsl:otherwise>
            <xsl:for-each select="current-group()">
              <xsl:apply-templates select="." mode="#current"/>
            </xsl:for-each>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each-group>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="  mediaobject[imageobject/imagedata/@fileref] 
                       | inlinemediaobject[imageobject/imagedata/@fileref]" 
                mode="hub2tei:dbk2tei" xpath-default-namespace="http://docbook.org/ns/docbook">
    <graphic url="{hub2tei:image-path(imageobject/imagedata/@fileref, root(.))}">
      <xsl:if test="imageobject/imagedata/@width">
        <xsl:attribute name="width" select="if (matches(imageobject/imagedata/@width,'^\.')) 
                                            then replace(imageobject/imagedata/@width,'^\.','0.') 
                                            else imageobject/imagedata/@width"/>
      </xsl:if>
      <xsl:if test="imageobject/imagedata/@depth">
        <xsl:attribute name="height" select="if (matches(imageobject/imagedata/@depth,'[0-9]$')) 
                                             then string-join((imageobject/imagedata/@depth,'pt'),'') 
                                             else imageobject/imagedata/@depth"/>
      </xsl:if>
      <xsl:if test="./@role">
        <xsl:attribute name="rend" select="@role"/>
      </xsl:if>
      <xsl:variable name="srcpaths" select="imageobject//@srcpath" as="xs:string*"/>
      <xsl:if test="exists($srcpaths)">
        <xsl:attribute name="srcpath" select="$srcpaths" separator=" "/>
      </xsl:if>
    </graphic>
    <xsl:apply-templates select="textobject" mode="#current"/>
  </xsl:template>
  
  <xsl:template match="textobject[parent::mediaobject | parent::inlinemediaobject]" mode="hub2tei:dbk2tei" 
    xpath-default-namespace="http://docbook.org/ns/docbook">
    <!-- Assumption: only inline content in the textobject. If there is block-level content, we’d probably have to 
      insert line breaks between them. -->
    <figDesc>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:value-of select="."/>
    </figDesc>
  </xsl:template>

  <!-- to be overwritten in adaptions: -->
  <xsl:function name="hub2tei:image-path" as="xs:string">
    <xsl:param name="path" as="xs:string"/>
    <xsl:param name="root" as="document-node()?"/>
    <xsl:sequence select="$path"/>
  </xsl:function>

  <xsl:variable name="hub:figure-note-role-regex" select="'^letex_figure_legend'" as="xs:string"/>

  <xsl:template match="dbk:note[dbk:para[matches(@role, $hub:figure-note-role-regex)]]" mode="hub2tei:dbk2tei" priority="2">
    <xsl:apply-templates select="node()" mode="hub2tei:dbk2tei"/>
  </xsl:template>

  <xsl:template match="dbk:note" mode="hub2tei:dbk2tei">
    <note>
      <xsl:apply-templates select="@*, node()" mode="hub2tei:dbk2tei"/>
    </note>
  </xsl:template>

  <xsl:template match="html:*" mode="hub2tei:tidy" xpath-default-namespace="html">
    <xsl:element name="{local-name()}">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:element>
  </xsl:template>

  <!-- prevent boxes that are set as tables to be converted to HTML tables -->
  <xsl:template match="*[local-name() = ('table', 'informaltable')][descendant-or-self::*[some $r in .//dbk:para/@role satisfies (matches($r, $tei:box-para-style-regex))]]" mode="cals2html-table">
    <!--    <xsl:apply-templates select="." mode="hub2tei:dbk2tei"/>-->
    <xsl:copy copy-namespaces="no">
      <xsl:copy-of select="@*"/>
      <xsl:copy-of select="node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="informaltable | table" mode="hub2tei:dbk2tei" xpath-default-namespace="http://docbook.org/ns/docbook">
    <table>
      <xsl:apply-templates select="@xml:id | @role" mode="#current"/>
      <xsl:if test="title">
        <head>
          <xsl:apply-templates select="title/@*, title/node()" mode="#current"/>
        </head>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="exists(tgroup)">
          <xsl:if test="not(@css:width)">
            <xsl:variable name="cell-width" select="sum(for $w in tgroup/colspec return number(replace($w/@colwidth, 'mm', '')))"/>
            <xsl:if test="number($cell-width)">
              <xsl:attribute name="css:width" select="concat($cell-width, 'mm')"/>
            </xsl:if>
          </xsl:if>
          <xsl:for-each select="./tgroup/(tbody union thead union tfoot)/row">
            <row>
              <xsl:for-each select="entry">
                <cell>
                  <xsl:if test="@namest">
                    <xsl:attribute name="cols" select="number(substring-after(@nameend, 'col')) - number(substring-after(@namest, 'col')) + 1"/>
                  </xsl:if>
                  <xsl:if test="@morerows &gt; 0">
                    <xsl:attribute name="rows" select="@morerows + 1"/>
                  </xsl:if>
                  <xsl:apply-templates select="@css:*" mode="#current"/>
                  <xsl:apply-templates mode="#current"/>
                </cell>
              </xsl:for-each>
            </row>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <row>
            <cell>
              <xsl:apply-templates mode="#current"/>
            </cell>
          </row>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="note">
        <note>
          <xsl:apply-templates select="note/@*, note/node()" mode="#current"/>
        </note>
      </xsl:if>
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

  <!--  <xsl:template match="tei:table[not(@type)]" mode="hub2tei:tidy">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:attribute name="type" select="'other'"/>
      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
  </xsl:template>-->

  <xsl:template match="/*" mode="hub2tei:tidy" priority="2">
    <xsl:copy>
      <xsl:namespace name="css" select="'http://www.w3.org/1996/css'"/>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="@remap" mode="hub2tei:dbk2tei"/>

</xsl:stylesheet>
