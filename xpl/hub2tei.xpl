<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step 
  xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step" 
  xmlns:hub2tei="http://www.le-tex.de/namespace/hub2tei"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  version="1.0"
  name="hub2tei"
  type="hub2tei:hub2tei">
  
  <p:input port="source"/>
  <p:output port="result"/>
  
  <p:option name="debug" required="false" select="'no'"/>
  <p:option name="debug-dir-uri" required="false" select="resolve-uri('debug')"/>
  
  <p:xslt template-name="main">
    <p:with-param name="debug" select="$debug"></p:with-param>
    <p:with-param name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:input port="stylesheet">
      <p:document href="../xsl/hub2tei.xsl"/>
    </p:input>
  </p:xslt>
  
</p:declare-step>