(:~ 
  генериует RDF/XML из trci-таблицы с использованием параметров 
:)

import module namespace rdfGen = 'rdf/generetor'
  at '../lib/rdf-generator.xqm';
import module namespace rdfGenTools = 'rdf/generetor/tools'
  at '../lib/rdf-generator-tools.xqm';
  
import module namespace parse = "http://www.iro37.ru/stasova/api/v1.1/parseXLSX" 
  at "../lib/xlsx/parseXLSX-to-TRCI.xqm";

let $dataPath := file:base-dir() || '..\example\реестр предметов\'
let $f := file:read-binary($dataPath|| "xlsx\Predmeti.xlsx")
let $trci := parse:xlsx($f, "")
let $params :=
  rdfGenTools:json-to-map(fetch:text($dataPath||'params\params.json')) 

return
  rdfGen:auto-trci-to-rdf($trci, $params)