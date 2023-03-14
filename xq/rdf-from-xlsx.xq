(:~ 
  генериует RDF/XML из trci-таблицы с использованием параметров 
:)

import module namespace rdfGen = 'rdf/generetor'
  at '../lib/rdf/main.xqm';
  
import module namespace parse = "http://www.iro37.ru/stasova/api/v1.1/parseXLSX" 
  at "../lib/xlsx/parseXLSX-to-TRCI.xqm";

let $f :=
  file:read-binary(file:base-dir() || "..\example\реестр-предметов\xlsx\Predmeti.xlsx")
let $trci := parse:xlsx($f, "")

return
  rdfGen:auto-trci-to-rdf($trci)