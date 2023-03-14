(:~ 
  генериует RDF из trci-таблицы
:)

import module namespace rdfGen = 'rdf/generetor'
  at '../lib/rdf/main.xqm';
import module namespace rdfGenTools = 'rdf/generetor/tools'
  at '../lib/rdf/tools.xqm';
import module namespace parse = "http://www.iro37.ru/stasova/api/v1.1/parseXLSX" 
  at "../lib/xlsx/parseXLSX-to-TRCI.xqm";

let $pathLocal := file:base-dir() || '..\example\реестр-предметов\'
let $filePath := $pathLocal|| "xlsx\Predmeti.xlsx"
let $paramsPath := $pathLocal||'params\params.json'
let $schemaPath := $pathLocal||"schemas\schema-2.json"

let $f := file:read-binary($filePath)
let $file := parse:xlsx($f, "")

(: создает параметры :)
let $params :=
  rdfGenTools:json-to-map(fetch:text($paramsPath))

(: создает схему с заполненными параметрами :)
let $schema :=
  rdfGenTools:schema(fetch:text($schemaPath), $params)

(: генерирует содержание RDF-файла :)
let $description :=
  rdfGen:description(<data>{$file}</data>, $schema)

return
   <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">{
     $description
   }</rdf:RDF>