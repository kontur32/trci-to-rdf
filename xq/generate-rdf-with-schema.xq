import module namespace rdfGen = 'rdf/generetor'
  at '../lib/rdf-generator.xqm';
import module namespace rdfGenTools = 'rdf/generetor/tools'
  at '../lib/rdf-generator-tools.xqm';

let $path := file:base-dir() || '..\example\'
let $pathSchemas := $path || 'schemas\'
let $pathTRCI := $path || 'TRCI\'

let $file := 
  fetch:xml($pathTRCI || "trci-example.xml")/file
let $context :=
  <data>{$file}</data>
let $params :=
  rdfGenTools:json-to-map(
    fetch:text($path||'params-example.json')
  )
let $schema :=
    fetch:text(
       $pathSchemas || "schema-example-2.json"
    )
let $rdf :=
   rdfGen:rdf($context, rdfGenTools:schema($schema, $params))

return
   $rdf