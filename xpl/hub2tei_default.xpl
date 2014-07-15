<?xml version="1.0" encoding="utf-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" 
  xmlns:c="http://www.w3.org/ns/xproc-step"  
  xmlns:cx="http://xmlcalabash.com/ns/extensions" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:bc="http://transpect.le-tex.de/book-conversion"
  xmlns:transpect="http://www.le-tex.de/namespace/transpect"  
  xmlns:letex="http://www.le-tex.de/namespace"
  xmlns:hub2tei="http://www.le-tex.de/namespace/hub2tei"
  version="1.0"
  name="hub2tei-driver">
  
  <p:option name="debug" required="false" select="'no'"/>
  <p:option name="debug-dir-uri" />
  
  <p:input port="source" primary="true"/>
  <p:input port="parameters" kind="parameter" primary="true"/>
  <p:input port="stylesheet"/>
  <p:output port="result" primary="true">
    <p:pipe port="result" step="tidy"/>
  </p:output>
  
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl" />
  <p:import href="http://transpect.le-tex.de/xproc-util/xslt-mode/xslt-mode.xpl"/>
  <p:import href="http://transpect.le-tex.de/xproc-util/xml-model/prepend-xml-model.xpl"/>
  <p:import href="http://transpect.le-tex.de/xproc-util/store-debug/store-debug.xpl"/>
  
  <p:identity name="create-model">
    <p:input port="source">
      <p:inline>
        <c:models>
          <c:model href="http://www.le-tex.de/resource/schema/tei-cssa/tei_all-cssa.rng"
            type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"/>
          <c:model href="http://www.le-tex.de/resource/schema/tei-cssa/tei/tei_all.rng"
            type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"/>            
        </c:models>
      </p:inline>
    </p:input>
  </p:identity>
  
  <p:sink/>
  
  <letex:xslt-mode msg="yes" prefix="hub2tei/40" mode="hub2tei:dbk2tei">
    <p:input port="source"><p:pipe port="source" step="hub2tei-driver"></p:pipe></p:input>
    <p:input port="stylesheet"><p:pipe step="hub2tei-driver" port="stylesheet"/></p:input>
    <p:input port="models"><p:pipe step="create-model" port="result"/></p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
  </letex:xslt-mode>
  
  <letex:xslt-mode msg="yes" prefix="hub2tei/99" mode="hub2tei:tidy" name="tidy">
    <p:input port="stylesheet"><p:pipe step="hub2tei-driver" port="stylesheet"/></p:input>
    <p:input port="models"><p:pipe step="create-model" port="result"/></p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
  </letex:xslt-mode>
  
  <p:delete match="@srcpath" name="drop-srcpaths"/>
  
  <letex:prepend-xml-model>
    <p:input port="models"><p:pipe step="create-model" port="result"/></p:input>
  </letex:prepend-xml-model>
  
  <letex:store-debug pipeline-step="hub2tei-driver/result">
    <p:with-option name="active" select="$debug" />
    <p:with-option name="base-uri" select="$debug-dir-uri" />
  </letex:store-debug>
  
  <p:sink/>
  
 </p:declare-step>