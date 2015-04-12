<?xml version="1.0" encoding="utf-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" 
  xmlns:c="http://www.w3.org/ns/xproc-step"  
  xmlns:cx="http://xmlcalabash.com/ns/extensions" 
  xmlns:transpect="http://www.le-tex.de/namespace/transpect"
  xmlns:hub2tei="http://www.le-tex.de/namespace/hub2tei"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  version="1.0"
  name="hub2tei"
  type="hub2tei:hub2tei"
  >
  
  <p:option name="debug" required="false" select="'no'"/>
  <p:option name="debug-dir-uri" select="'debug'"/>
  <p:option name="status-dir-uri" required="false" select="'debug/status'"/>
  
  <p:input port="source" primary="true" />
  <p:input port="paths" kind="parameter" primary="true"/>
  <p:output port="result" primary="true" />
  
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl" />
  <p:import href="http://transpect.le-tex.de/book-conversion/converter/xpl/dynamic-transformation-pipeline.xpl"/>

  <transpect:dynamic-transformation-pipeline load="hub2tei/hub2tei_driver"
    fallback-xsl="http://transpect.le-tex.de/hub2tei/xsl/hub2tei.xsl"
    fallback-xpl="http://transpect.le-tex.de/hub2tei/xpl/hub2tei_default.xpl">
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:input port="additional-inputs"><p:empty/></p:input>
    <p:input port="options"><p:empty/></p:input>
  </transpect:dynamic-transformation-pipeline>
  
</p:declare-step>
