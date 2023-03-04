import module namespace rdfGen = 'rdf/generetor'
  at '../lib/rdf-generator.xqm';
import module namespace rdfGenTools = 'rdf/generetor/tools'
  at '../lib/rdf-generator-tools.xqm';
import module namespace genSchema = 'rdf/generetor/schema'
  at '../lib/rdf-generator-schema.xqm';


let $dataPath := file:base-dir() || '..\example\'
let $context := <data>{fetch:xml($dataPath||"trci-example.xml")/file}</data>
let $params :=
  rdfGenTools:json-to-map(fetch:text($dataPath||'params-example.json')) 

return
  rdfGen:trci-to-rdf($context, $params)