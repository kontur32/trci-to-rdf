(:~ 
  генериует RDF/XML из trci-таблицы с использованием параметров 
:)

import module namespace rdfFile = 'rdf/generetor/file'
  at '../lib/rdf/file.xqm';
  
import module namespace parse = "http://www.iro37.ru/stasova/api/v1.1/parseXLSX" 
  at "../lib/xlsx/parseXLSX-to-TRCI.xqm";

let $f :=
  file:read-binary(file:base-dir() || "..\example\реестр-предметов\xlsx\Predmeti.xlsx")
let $trci := parse:xlsx($f, "")

return
  rdfFile:auto-trci-to-rdf($trci)