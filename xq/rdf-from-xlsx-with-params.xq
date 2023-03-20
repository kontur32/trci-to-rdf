(:~ 
  генериует RDF/XML из trci-таблицы с использованием параметров 
:)

import module namespace rdfFile = 'rdf/generetor/file'
  at '../lib/rdf/file.xqm';
  
import module namespace rdfGenTools = 'rdf/generetor/tools'
  at '../lib/rdf/tools.xqm';
  
import module namespace trci = "http://www.iro37.ru/stasova/api/v1.1/parseXLSX" 
  at "../lib/xlsx/parseXLSX-to-TRCI.xqm";

let $dataPath := file:base-dir() || '..\example\реестр-предметов\'
let $f := file:read-binary($dataPath|| "xlsx\Predmeti.xlsx")
let $trci := trci:xlsx($f, "")
let $params :=
  rdfGenTools:json-to-map(json:parse(fetch:text($dataPath||'params\params.json'))/json) 

return
  rdfFile:auto-trci-to-rdf($trci, $params)