(:~ 
  генериует RDF из для trci-файла (несколько таблиц) с использованием параметров 
:)

import module namespace rdfGen = 'rdf/generetor'
  at '../lib/rdf-generator.xqm';
import module namespace rdfGenTools = 'rdf/generetor/tools'
  at '../lib/rdf-generator-tools.xqm';
import module namespace rdfGenElements = 'rdf/generetor/elements'
  at '../lib/rdf-generator-elements.xqm';
  
let $file := 
  fetch:xml(file:base-dir() || '..\example\TRCI\trci-example.xml')/file 
let $context := <data>{$file}</data>
let $path :=  
    'http://a.roz37.ru/lipers/семантический.контракт/мисис/анкета-преподавателя/'

let $params :=
  rdfGenTools:json-to-map(fetch:text(iri-to-uri($path || 'params.json')))
let $schema := fetch:text(iri-to-uri($path || "schema.json"))

let $descriptions :=
  for $i in rdfGenTools:schema($schema, $params)/_
  let $params :=
    rdfGenTools:json-to-map(fetch:text(iri-to-uri($i/parameters/text())))
  let $schema :=
    fetch:text(iri-to-uri($i/URL/text()))
  return
    rdfGen:description($context, rdfGenTools:schema($schema, $params))
    
return
  rdfGenElements:RDF($descriptions)