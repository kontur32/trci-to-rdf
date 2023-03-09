(:~ 
  генериует RDF из trci-таблицы
:)

import module namespace rdfGen = 'rdf/generetor'
  at '../lib/rdf-generator.xqm';
import module namespace rdfGenTools = 'rdf/generetor/tools'
  at '../lib/rdf-generator-tools.xqm';
import module namespace rdfGenElements = 'rdf/generetor/elements'
  at '../lib/rdf-generator-elements.xqm';

let $path := file:base-dir() || '..\example\'
let $pathSchemas := $path || 'schemas\'
let $pathTRCI := $path || 'TRCI\'

let $file := fetch:xml($pathTRCI || "список-ппс.xml")/file
let $context := <data>{$file}</data>
let $params :=rdfGenTools:json-to-map(fetch:text($path||'params-example.json'))
let $schema := fetch:text($pathSchemas || "schema-список-ппс.json")
let $descriptions := rdfGen:description($context, rdfGenTools:schema($schema, $params))
return
   rdfGenElements:RDF($descriptions)