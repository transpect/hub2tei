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
          hub:hierarchize-according-to-role-regexes
          hub:title
          edu
          tidy" priority="-1">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*, node()" mode="#current" />
    </xsl:copy>
  </xsl:template>


  <!-- Processing pipeline: -->

  <xsl:variable name="preprocess-hub">
    <xsl:apply-templates select="/" mode="preprocess-hub" />
  </xsl:variable>

  <xsl:variable name="insert-sep">
    <xsl:apply-templates select="$preprocess-hub" mode="insert-sep" />
  </xsl:variable>

  <xsl:variable name="inline-lists">
    <xsl:apply-templates select="$insert-sep" mode="inline-lists" />
  </xsl:variable>

  <xsl:variable name="hub:hierarchize-according-to-role-regexes">
    <xsl:apply-templates select="$inline-lists" mode="hub:hierarchize-according-to-role-regexes" />
  </xsl:variable>

  <xsl:variable name="group-other-sections">
    <xsl:apply-templates select="$hub:hierarchize-according-to-role-regexes" mode="group-other-sections" />
  </xsl:variable>

  <xsl:variable name="dbk2tei">
    <xsl:apply-templates select="$group-other-sections" mode="dbk2tei" />
  </xsl:variable>

  <xsl:variable name="join-emph">
    <xsl:apply-templates select="$dbk2tei" mode="join-emph" />
  </xsl:variable>

  <xsl:variable name="tabbed-lists">
    <xsl:apply-templates select="$join-emph" mode="tabbed-lists" />
  </xsl:variable>

  <xsl:variable name="edu">
    <xsl:apply-templates select="$tabbed-lists" mode="edu" />
  </xsl:variable>

  <xsl:variable name="tidy">
    <xsl:apply-templates select="$edu" mode="tidy" />
  </xsl:variable>

  <xsl:template name="main">
    <xsl:if test="$debug = 'yes'">
      <xsl:call-template name="debug-hub2tei" />
    </xsl:if>
    <xsl:processing-instruction name="xml-model">href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"</xsl:processing-instruction>
    <xsl:processing-instruction name="xml-model">href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"</xsl:processing-instruction>
    <xsl:sequence select="$tidy" />
  </xsl:template>

  <xsl:template name="debug-hub2tei">
    <xsl:result-document href="{resolve-uri(concat($debug-dir-uri, '/00.src.xml'))}" format="debug">
      <xsl:sequence select="/" />
    </xsl:result-document>
    <xsl:result-document href="{resolve-uri(concat($debug-dir-uri, '/02.preprocess-hub.xml'))}" format="debug">
      <xsl:sequence select="$preprocess-hub" />
    </xsl:result-document>
    <xsl:result-document href="{resolve-uri(concat($debug-dir-uri, '/07.inline-lists.xml'))}" format="debug">
      <xsl:sequence select="$inline-lists" />
    </xsl:result-document>
    <xsl:result-document href="{resolve-uri(concat($debug-dir-uri, '/20.hierarchize.xml'))}" format="debug">
      <xsl:sequence select="$hub:hierarchize-according-to-role-regexes" />
    </xsl:result-document>
    <xsl:result-document href="{resolve-uri(concat($debug-dir-uri, '/22.group-other-sections.xml'))}" format="debug">
      <xsl:sequence select="$group-other-sections" />
    </xsl:result-document>
    <xsl:result-document href="{resolve-uri(concat($debug-dir-uri, '/40.dbk2tei.xml'))}" format="debug">
      <xsl:sequence select="$dbk2tei" />
    </xsl:result-document>
    <xsl:result-document href="{resolve-uri(concat($debug-dir-uri, '/46.join-emph.xml'))}" format="debug">
      <xsl:sequence select="$join-emph" />
    </xsl:result-document>
    <xsl:result-document href="{resolve-uri(concat($debug-dir-uri, '/48.tabbed-lists.xml'))}" format="debug">
      <xsl:sequence select="$tabbed-lists" />
    </xsl:result-document>
    <xsl:result-document href="{resolve-uri(concat($debug-dir-uri, '/50.edu.xml'))}" format="debug">
      <xsl:sequence select="$edu" />
    </xsl:result-document>
    <xsl:result-document href="{resolve-uri(concat($debug-dir-uri, '/99.tidy.xml'))}" format="debug">
      <xsl:sequence select="$tidy" />
    </xsl:result-document>
  </xsl:template>


  <!-- mode: preprocess-hub -->

  <xsl:template match="@css:font-family" mode="preprocess-hub" />

  <xsl:template match="@xpath | @srcpath | dbk:annotation" mode="preprocess-hub" />

  <xsl:template match="@xml:lang" mode="preprocess-hub">
    <xsl:attribute name="xml:lang" select="replace(., '-\p{Lu}+$', '')" />
  </xsl:template>

  <!-- collateral -->
  <xsl:template match="dbk:para/dbk:phrase[every $att in @* satisfies $att/self::attribute(xml:lang)]" mode="preprocess-hub">
    <xsl:apply-templates mode="#current" />
  </xsl:template>

  <!-- collateral -->
  <xsl:template match="dbk:para/dbk:phrase[@role eq 'hub:identifier'][. eq '&#xF031;']" mode="preprocess-hub"  />


  <!-- mode: insert-sep -->

  <xsl:variable name="colon-regex-x" as="xs:string"
    select="'
             ^(
                ([12]\.(/mehrmaliges)?\s+)?
                (Hören|Lesen)
                (/(Hören|Lesen))?
                (\s+\((Global|Detail)verstehen\))?
              |
                Hör-/Sehverstehen
              |
                Sprechen
              |
                Schreiben
              |
                Grammatische[ ]Strukturen
              |
                Wortfelder
              |
                Spelling[ ]Course
              |
                TIP\p{Zs}+\p{Pd}\p{Zs}+The\p{Zs}+Vocabulary
             ):
            '" />

  <xsl:template match="dbk:para[matches(., $colon-regex-x, 'x')]
                       //text()[
                         contains(., ':')
                       ][
                         . is (ancestor::dbk:para[1]//text()[contains(., ':')])[1]
                       ]" mode="insert-sep">
    <xsl:analyze-string select="." regex=":">
      <xsl:matching-substring>
        <sep xmlns="http://docbook.org/ns/docbook" type="colon"/>
      </xsl:matching-substring>
      <xsl:non-matching-substring>
        <xsl:value-of select="."/>
      </xsl:non-matching-substring>
    </xsl:analyze-string>
  </xsl:template>

  <xsl:variable name="full-stop-regex-x" as="xs:string"
    select="'
             ^(
                Getting[ ]to[ ]know[ ]your[ ]English[ ]book:[ ]The[ ]Vocabulary
              |
                Discovering[ ]the[ ]book
             )\.
            '" />

  <xsl:template match="dbk:para[matches(., $full-stop-regex-x, 'x')]
                       //text()[
                         contains(., '.')
                       ][
                         . is (ancestor::dbk:para[1]//text()[contains(., '.')])[1]
                       ]" mode="insert-sep">
    <xsl:analyze-string select="." regex="\.">
      <xsl:matching-substring>
        <sep xmlns="http://docbook.org/ns/docbook" type="full-stop"/>
      </xsl:matching-substring>
      <xsl:non-matching-substring>
        <xsl:value-of select="."/>
      </xsl:non-matching-substring>
    </xsl:analyze-string>
  </xsl:template>


  <!-- mode: inline-lists -->

  <xsl:template mode="inline-lists"
    match="dbk:para[not(@role)][contains(., '•')]" 
    xmlns="http://docbook.org/ns/docbook">
    <xsl:variable name="inline-lists-insert-sep" as="element(dbk:para)">
      <xsl:apply-templates select="." mode="inline-lists-insert-sep" />
    </xsl:variable>
    <xsl:variable name="leaves" as="node()+" select="$inline-lists-insert-sep//node()[not(node())]" />
    <itemizedlist rend="inline bullet">
      <xsl:for-each-group select="$leaves" group-starting-with="dbk:sep">
        <xsl:variable name="restricted-to" select="current-group()/ancestor-or-self::node()" as="node()+"/>
	<xsl:variable name="item" as="element(dbk:item)">
          <item>
            <xsl:apply-templates select="$inline-lists-insert-sep/node()" mode="inline-lists-slice">
              <xsl:with-param name="restricted-to" select="$restricted-to" tunnel="yes"/>
            </xsl:apply-templates>
          </item>
	</xsl:variable>
        <xsl:apply-templates select="$item" mode="inline-lists-dissolve-empty-phrases" />
    </xsl:for-each-group>
    </itemizedlist>
  </xsl:template>

  <xsl:template match="dbk:item//text()[. is (ancestor::dbk:item[1]//text())[1]]" mode="inline-lists-dissolve-empty-phrases">
    <xsl:value-of select="replace(., '^\s+', '')" />
  </xsl:template>

  <!-- collateral: after split at seg, the paras after seg may start with unwanted WS  -->
  <xsl:template match="dbk:para[ancestor::*[1]/self::tei:div[@type eq 'pg']]//text()[
                         . is (ancestor::dbk:para[ancestor::*[1]/self::tei:div[@type eq 'pg']]//text())[1]
                       ]" mode="inline-lists">
    <xsl:value-of select="replace(., '^\s+', '')" />
  </xsl:template>

  <xsl:template match="dbk:item//text()[. is (ancestor::dbk:item[1]//text())[last()]]" mode="inline-lists-dissolve-empty-phrases">
    <xsl:value-of select="replace(., '\s+$', '')" />
  </xsl:template>

  <xsl:template match="dbk:item//text()[. is (ancestor::dbk:item[1]//text())[last()]][. is (ancestor::dbk:item[1]//text())[1]]" 
		mode="inline-lists-dissolve-empty-phrases" priority="2">
    <xsl:value-of select="replace(., '^\s+(.*?)\s*$', '$1')" />
  </xsl:template>

  <xsl:template match="text()" mode="inline-lists-insert-sep" xmlns="http://docbook.org/ns/docbook">
    <xsl:analyze-string select="." regex="•">
      <xsl:matching-substring>
        <sep/>
      </xsl:matching-substring>
      <xsl:non-matching-substring>
        <xsl:value-of select="."/>
      </xsl:non-matching-substring>
    </xsl:analyze-string>
  </xsl:template>

  <xsl:template match="node()" mode="inline-lists-slice" xmlns="http://docbook.org/ns/docbook">
    <xsl:param name="restricted-to" as="node()+" tunnel="yes"/>
    <xsl:if test="exists(. intersect $restricted-to)">
      <xsl:copy copy-namespaces="no">
        <xsl:copy-of select="@*" />
        <xsl:apply-templates mode="#current">
          <xsl:with-param name="restricted-to" select="$restricted-to" tunnel="yes"/>
        </xsl:apply-templates>
      </xsl:copy>
    </xsl:if>
  </xsl:template>

  <xsl:template match="dbk:sep" mode="inline-lists-slice" />


  <!-- collateral -->
  <!-- Swallows significant WS, disabled: -->
  <xsl:template match="dbk:phrase[every $n in node() satisfies $n/self::text()[matches(., '^\s*$')]]" mode="group-other-sections_DISABLED" />
  <xsl:template match="dbk:phrase[empty(node())]" mode="group-other-sections" />

  <!-- collateral -->
  <xsl:template match="dbk:anchor[@role = ('start', 'end')]" mode="group-other-sections" />

  <xsl:variable name="hub2tei:box-section-start-role-regex" as="xs:string"
    select="'^(Box)$'"/>

  <xsl:variable name="hub2tei:box-section-end-role-regex" as="xs:string"
    select="'^(Box_?end)$'"/>

  <xsl:variable name="hub2tei:box-section-attr-values" as="xs:string"
    select="'hru-infobox'"/>

  <xsl:template match="*[dbk:para[matches(@role, $hub2tei:box-section-start-role-regex)]]" 
    mode="group-other-sections" xmlns="http://docbook.org/ns/docbook">
    <xsl:copy copy-namespaces="no">
      <xsl:copy-of select="@*" />
      <xsl:for-each-group select="*" group-starting-with="dbk:para[matches(@role, $hub2tei:box-section-start-role-regex)]">
        <xsl:choose>
          <xsl:when test="self::dbk:para[matches(@role, $hub2tei:box-section-start-role-regex)]">
            <xsl:for-each-group select="current-group()" group-ending-with="dbk:para[matches(@role, $hub2tei:box-section-end-role-regex)]">
              <xsl:choose>
                <!-- a single paragraph -->
                <xsl:when test="current-group()[last() and position() = 2]/self::dbk:para[matches(@role, $hub2tei:box-section-end-role-regex)]">
                  <p rend="{$hub2tei:box-section-attr-values}" xmlns="http://www.tei-c.org/ns/1.0">
                    <xsl:apply-templates select="@* except @role, node()" mode="#current"/>
                  </p>
                </xsl:when>
                <xsl:when test="current-group()[last()]/self::dbk:para[matches(@role, 'Box_?end')]">
                  <section role="{$hub2tei:box-section-attr-values}">
                    <xsl:apply-templates select="." mode="hub:title"/>
                    <xsl:apply-templates select="current-group()[position() = (2 to last() - 1)]" mode="#current"/>
                  </section>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:apply-templates select="current-group()" mode="#current"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:for-each-group>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="current-group()" mode="#current"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each-group>
    </xsl:copy>
  </xsl:template>


  <xsl:variable name="margin-para-styles" as="xs:string*"
    select="('seealso', 'see_also', 'see_also_(optional)', 'Phase_DiffAlt', 'Standard2', 'KV')"/>

  <xsl:function name="hub2tei:is-marginal-content" as="xs:boolean">
    <xsl:param name="elt" as="node()" />
    <xsl:sequence select="$elt/self::dbk:para[@role = $margin-para-styles]
                          or
                          $elt/self::dbk:informaltable[ends-with(@role, 'in_margin')]
                          " />
  </xsl:function>


  <xsl:template match="*[dbk:para]" mode="hub:hierarchize-according-to-role-regexes" xmlns="http://www.tei-c.org/ns/1.0">
    <xsl:copy copy-namespaces="no">
      <xsl:copy-of select="@*" />
      <xsl:sequence select="hub:hierarchize-according-to-role-regexes(
                              *,
                              $role-regexes-x,
                              *[
                                some $r in $role-regexes-x satisfies
                                (matches(@role, $r, 'x'))
                              ]
                            )" />
    </xsl:copy>
  </xsl:template>
  
  <xsl:function name="hub:hierarchize-according-to-role-regexes" as="element(*)*" xmlns="http://docbook.org/ns/docbook">
    <xsl:param name="elts" as="element(*)*"/>
    <xsl:param name="role-regexes" as="xs:string*" />
    <xsl:param name="all-headings" as="element(*)*" />
    <xsl:choose>
      <xsl:when test="count($role-regexes) ge 1">
        <xsl:choose>
          <xsl:when test="exists($elts intersect $all-headings)">
            <xsl:for-each-group select="$elts" group-starting-with="*[matches(@role, $role-regexes[1], 'x')]">
              <xsl:choose>
                <xsl:when test="matches(@role, $role-regexes[1], 'x')">
                  <section>
                    <xsl:apply-templates select="." mode="hub:title" />
                    <xsl:sequence select="hub:hierarchize-according-to-role-regexes(
                                            current-group()[position() gt 1], 
                                            $role-regexes[position() gt 1], 
                                            $all-headings
                                          )" />
                  </section>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:sequence select="hub:hierarchize-according-to-role-regexes(
                                          current-group(), 
                                          $role-regexes[position() gt 1], 
                                          $all-headings
                                        )" />
                </xsl:otherwise>
              </xsl:choose>
            </xsl:for-each-group>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="$elts" mode="hub:hierarchize-according-to-role-regexes" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="$elts" mode="hub:hierarchize-according-to-role-regexes" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:template match="dbk:para" mode="hub:title" xmlns="http://docbook.org/ns/docbook">
    <title>
      <xsl:apply-templates select="@*, node()" mode="#current" />
    </title>
  </xsl:template>

  <xsl:variable name="hub2tei:unit-role-regex-x" as="xs:string"
    select="'^(Unit_?Number)$'" />
  <xsl:variable name="hub2tei:part-role-regex-x" as="xs:string"
    select="'^(Part(_blue)?)$'" />
  <xsl:variable name="hub2tei:pageref-role-regex-x" as="xs:string"
    select="'^(SB-Seite)$'" />
  <xsl:variable name="hub2tei:exercise-role-regex-x" as="xs:string"
    select="'^(Exercise(_blue)?)$'" />
  <xsl:variable name="hub2tei:phase-or-section-role-regex-x" as="xs:string"
    select="'^(PhaseOrSection(_blue)?|Tips)$'" />
  <xsl:variable name="hub2tei:phase-diffalt-role-regex-x" as="xs:string"
    select="'^(Phase_DiffAlt)$'" />

  <xsl:variable name="role-regexes-x" as="xs:string+"
    select="(
              $hub2tei:unit-role-regex-x,
              $hub2tei:part-role-regex-x,
              $hub2tei:pageref-role-regex-x,
              $hub2tei:exercise-role-regex-x,
              $hub2tei:phase-or-section-role-regex-x,
              $hub2tei:phase-diffalt-role-regex-x
            )" />



  <xsl:template match="/*/@xml:base" mode="dbk2tei">
    <xsl:attribute name="xml:base" select="replace(., '\.hub\.xml$', '.tei.xml')" />
  </xsl:template>

  <xsl:template match="/dbk:*" mode="dbk2tei" xmlns="http://www.tei-c.org/ns/1.0">
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

  <xsl:template match="processing-instruction('xml-model')" mode="dbk2tei" />

  <xsl:template match="dbk:section" mode="dbk2tei" xmlns="http://www.tei-c.org/ns/1.0">
    <div>
      <xsl:apply-templates select="dbk:title/@role, @*, node()" mode="#current" />
    </div>
  </xsl:template>

  <xsl:variable name="hub2tei:title-role-regex" as="xs:string"
    select="'^(Unit_?Title)$'"/>

  <xsl:template match="  dbk:para[matches(@role, $hub2tei:title-role-regex)]
                       | dbk:title
                       | dbk:para[@head-sep]
                       " 
    mode="dbk2tei" xmlns="http://www.tei-c.org/ns/1.0">
    <head>
      <xsl:apply-templates select="@* except @role, node()" mode="#current" />
    </head>
  </xsl:template>

  <xsl:template match="dbk:para/@head-sep" mode="dbk2tei">
    <xsl:attribute name="rend" select="'run-in colon'" />
  </xsl:template>

  <xsl:template match="dbk:para[@head-sep]/dbk:phrase/@css:font-weight" mode="dbk2tei" />

  <xsl:template match="dbk:para" mode="dbk2tei" xmlns="http://www.tei-c.org/ns/1.0">
    <p>
      <xsl:apply-templates select="@*, node()" mode="#current" />
    </p>
  </xsl:template>

  <xsl:template match="dbk:link" mode="dbk2tei" xmlns="http://www.tei-c.org/ns/1.0">
    <link>
      <xsl:apply-templates select="@*, node()" mode="#current" />
    </link>
  </xsl:template>

  <xsl:template match="@xlink:href" mode="dbk2tei">
    <xsl:attribute name="target" select="." />
  </xsl:template>

  <xsl:template match="dbk:footnote" mode="dbk2tei" xmlns="http://www.tei-c.org/ns/1.0">
    <note type="footnote">
      <xsl:apply-templates select="@*, node()" mode="#current" />
    </note>
  </xsl:template>

  <xsl:template match="dbk:br" mode="dbk2tei" xmlns="http://www.tei-c.org/ns/1.0">
    <seg type="br" />
  </xsl:template>

  <xsl:template match="dbk:tab" mode="dbk2tei" xmlns="http://www.tei-c.org/ns/1.0">
    <seg type="{if(@role) then @role else 'tab'}">
      <xsl:apply-templates mode="#current"/>
    </seg>
  </xsl:template>

  <xsl:template match="dbk:phrase" mode="dbk2tei" xmlns="http://www.tei-c.org/ns/1.0">
    <seg>
      <xsl:apply-templates select="@*, node()" mode="#current" />
    </seg>
  </xsl:template>

  <xsl:template match="dbk:phrase[@css:font-style eq 'italic']" mode="dbk2tei" xmlns="http://www.tei-c.org/ns/1.0">
    <foreign xml:lang="en">
      <xsl:apply-templates select="@* except @css:font-style, node()" mode="#current" />
    </foreign>
  </xsl:template>

  <xsl:template match="@role" mode="dbk2tei">
    <xsl:attribute name="type" select="." />
  </xsl:template>

  <xsl:template match="dbk:phrase[@role eq 'footnote_reference'][dbk:footnote][count(node()) eq 1]" mode="dbk2tei">
    <xsl:apply-templates mode="#current" />
  </xsl:template>

  <xsl:template match="dbk:itemizedlist" mode="dbk2tei" xmlns="http://www.tei-c.org/ns/1.0">
    <list>
      <xsl:apply-templates select="@*, node()" mode="#current" />
    </list>
  </xsl:template>

  <xsl:template match="dbk:item" mode="dbk2tei" xmlns="http://www.tei-c.org/ns/1.0">
    <xsl:element name="{local-name()}">
      <xsl:apply-templates select="@*, node()" mode="#current" />
    </xsl:element>
  </xsl:template>

  <xsl:template match="mediaobject[imageobject/imagedata/@fileref]" mode="dbk2tei" 
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

  <xsl:template match="informaltable | table" mode="dbk2tei"
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

  <xsl:template match="*[tei:seg]" mode="join-emph">
    <xsl:copy copy-namespaces="no">
      <xsl:copy-of select="@*" />
      <xsl:for-each-group select="node()" group-adjacent="hub2tei:seg-signature(.)">
        <xsl:choose>
          <xsl:when test="self::tei:seg">
            <xsl:copy copy-namespaces="no">
              <xsl:copy-of select="@*" />
              <xsl:apply-templates select="current-group()" mode="join-emph-unwrap" />
            </xsl:copy>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="current-group()" mode="#current" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each-group>
    </xsl:copy>
  </xsl:template>

  <xsl:function name="hub2tei:attr-hashes" as="xs:string*">
    <xsl:param name="elt" as="node()*" />
    <xsl:perform-sort>
      <xsl:sort/>
      <xsl:sequence select="for $a in ($elt/@*[not(name() = 'xml:id')]) return hub2tei:attr-hash($a)" />
    </xsl:perform-sort>
  </xsl:function>

  <xsl:function name="hub2tei:attr-hash" as="xs:string">
    <xsl:param name="att" as="attribute(*)" />
    <xsl:sequence select="concat(name($att), '__=__', $att)" />
  </xsl:function>

  <xsl:function name="hub2tei:attname" as="xs:string">
    <xsl:param name="hash" as="xs:string" />
    <xsl:value-of select="replace($hash, '__=__.+$', '')" />
  </xsl:function>

  <xsl:function name="hub2tei:attval" as="xs:string">
    <xsl:param name="hash" as="xs:string" />
    <xsl:value-of select="replace($hash, '^.+__=__', '')" />
  </xsl:function>

  <xsl:function name="hub2tei:signature" as="xs:string*">
    <xsl:param name="elt" as="element(*)?" />
    <!-- don't join shortcuts: -->
    <xsl:variable name="tiebreaker-for-shortcut" as="xs:string">
      <xsl:choose>
        <xsl:when test="$elt/@type eq 'hub2tei:shortcut'">
          <xsl:sequence select="string($elt)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="''"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:sequence select="if (exists($elt)) 
                          then string-join((name($elt), $tiebreaker-for-shortcut, hub2tei:attr-hashes($elt)), '___')
                          else '' " />
  </xsl:function>

  <!-- If a span, return its hash. 
       If a whitespace text node in between two spans of same hash, return their hash.
       Otherwise, return the empty string. -->
  <xsl:function name="hub2tei:seg-signature" as="xs:string">
    <xsl:param name="node" as="node()" />
    <xsl:sequence select="if ($node/self::tei:seg) 
                          then hub2tei:signature($node)
                          else 
                            if ($node/self::*)
                            then ''
                            else
                              if ($node/self::text()
                                    [matches(., '^\s+$')]
                                    [hub2tei:signature($node/preceding-sibling::*[1]) eq hub2tei:signature($node/following-sibling::*[1])]
                                 )
                              then hub2tei:signature($node/preceding-sibling::*[1])
                              else ''
                          " />
  </xsl:function>

  <xsl:template match="tei:seg" mode="join-emph-unwrap">
    <xsl:apply-templates mode="join-emph" />
  </xsl:template>


  <!-- As primitive as it may be. Doesn't work for nested lists. -->
  <xsl:template match="*[p[seg[@type eq 'hub:identifier']][dbk:tab]]" mode="tabbed-lists"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.tei-c.org/ns/1.0">
    <xsl:copy copy-namespaces="no">
      <!-- as a collateral, @n will be inserted for divs when processing their @role -->
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:for-each-group select="node()" group-adjacent="hub2tei:list-type(.)">
        <xsl:variable name="type" select="current-grouping-key()" as="xs:string?" />
        <xsl:choose>
          <xsl:when test="$type ne ''">
            <list type="{$type}">
              <xsl:apply-templates select="current-group()" mode="#current" />
            </list>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="current-group()" mode="#current" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each-group>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="p[seg[@type eq 'hub:identifier']][dbk:tab]" mode="tabbed-lists"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.tei-c.org/ns/1.0">
    <item n="{seg[@type eq 'hub:identifier']}">
      <xsl:apply-templates mode="#current" />
    </item>
  </xsl:template>

  <xsl:template match="p/seg[@type eq 'hub:identifier'][following-sibling::*[1]/self::dbk:tab]" mode="tabbed-lists"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" />

  <xsl:template match="tei:p[tei:seg[@type eq 'hub:identifier']]/dbk:tab" mode="tabbed-lists" />

  <xsl:function name="hub2tei:list-type" as="xs:string?">
    <xsl:param name="para" as="node()" />
    <xsl:choose>
      <xsl:when test="$para/self::tei:p/tei:seg[@type eq 'hub:identifier'][matches(., '\w')]">
        <xsl:sequence select="'ordered'" />
      </xsl:when>
      <xsl:when test="$para/self::tei:p/tei:seg[@type eq 'hub:identifier']">
        <xsl:sequence select="'unordered'" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="''" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:template match="head//text()[. is (ancestor::head//text())[1]][matches(., '^\d+[\p{Zs}&#x2003;]')]" mode="tabbed-lists" 
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.tei-c.org/ns/1.0">
    <xsl:value-of select="replace(., '^\d+[\p{Zs}&#x2003;]+', '')" />
  </xsl:template>

  <xsl:template match="div[head//text()[. is (ancestor::head//text())[1]][matches(., '^\d+[\p{Zs}&#x2003;]')]]/@type" mode="tabbed-lists"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.tei-c.org/ns/1.0">
    <xsl:copy/>
    <xsl:attribute name="n" select="replace(../head//text()[. is (ancestor::head//text())[1]], '^(\d+)[\p{Zs}&#x2003;]+.*$', '$1')" />
  </xsl:template>

  <xsl:template match="tei:seg[not(@*)]" mode="tidy">
    <xsl:apply-templates mode="#current" />
  </xsl:template>

  <xsl:template match="tei:table[not(@type)]" mode="tidy">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*" mode="#current" />
      <xsl:attribute name="type" select="'other'" />
      <xsl:apply-templates mode="#current" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="/*" mode="tidy">
    <xsl:copy>
      <xsl:namespace name="edu" select="'http://www.le-tex.de/namespace/edu'" />
      <xsl:namespace name="css" select="'http://www.w3.org/1996/css'" />
      <xsl:apply-templates select="@*, node()" mode="#current" />
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
