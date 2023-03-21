(:~ 
  генериует RDF из trci-таблицы
:)

import module namespace rdfGen = 'rdf/generetor'
  at '../lib/rdf/main.xqm';
import module namespace rdfGenTools = 'rdf/generetor/tools'
  at '../lib/rdf/tools.xqm';
import module namespace rdfGenElements = 'rdf/generetor/elements'
  at '../lib/rdf/elements.xqm';

let $baseURL := 
  "http://a.roz37.ru/lipers/семантический.контракт/мисис/анкета-преподавателя/"

let $pathLocal := file:base-dir() || '..\example\'
let $pathLocalSchemas := $pathLocal || 'schemas\'
let $pathLocalTRCI := $pathLocal || 'TRCI\'


let $filePath := 
  (
    $pathLocalTRCI || "TRCI-example.xml",
    $pathLocalTRCI || "Тригуб Наталья Александровна.xml",
    $pathLocalTRCI || "список-ппс.xml"
  )[2]

let $paramsPath :=
  (
    $pathLocal||'params-example.json',
    iri-to-uri($baseURL || "анкетные-данные/params.json"),
    iri-to-uri($baseURL || "интересы-и-достижения/params.json"),
    iri-to-uri($baseURL || "научные-публикации/params.json")
  )[2]

let $schemaPath :=
  (
    $pathLocalSchemas || "schema-список-ппс.json",
    $pathLocalSchemas || "schema-example-2.json",
    iri-to-uri($baseURL || "анкетные-данные/schema.json"),
    iri-to-uri($baseURL || "интересы-и-достижения/schema.json"),
    iri-to-uri($baseURL || "научные-публикации/schema.json")
  )[3]


let $context := <data>{fetch:xml($filePath)/file}</data>
let $params := rdfGenTools:json-to-map(fetch:text($paramsPath))
let $schema := fetch:text($schemaPath)

let $descriptions := rdfGen:tables($context, rdfGenTools:schema($schema, $params))
return
   rdfGenElements:RDF($descriptions)