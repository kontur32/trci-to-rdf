(:~ 
  генериует шаблон схемы для trci-таблицы с использованием параметров 
 :)

import module namespace rdfGen = 'rdf/generetor'
  at '../lib/rdf-generator.xqm';
import module namespace rdfGenTools = 'rdf/generetor/tools'
  at '../lib/rdf-generator-tools.xqm';
import module namespace genSchema = 'rdf/generetor/schema'
  at '../lib/rdf-generator-schema.xqm';

let $dataPath := 
  file:base-dir() || '..\example\'

let $table :=
  fetch:xml($dataPath || "trci-example.xml")/file/table

let $params :=
  rdfGenTools:json-to-map(fetch:text($dataPath||'params-example.json'))

return
  genSchema:Sample($table)