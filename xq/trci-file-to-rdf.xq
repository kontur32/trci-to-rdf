(:~ 
  генериует RDF из для trci-файла (несколько таблиц) с использованием параметров 
:)
import module namespace parse = "http://www.iro37.ru/stasova/api/v1.1/parseXLSX" 
  at "../lib/xlsx/parseXLSX-to-TRCI.xqm";
  
import module namespace rdfGen = 'rdf/generetor'
  at '../lib/rdf/main.xqm';
import module namespace rdfFile = 'rdf/generetor/file'
  at '../lib/rdf/file.xqm';
import module namespace rdfGenTools = 'rdf/generetor/tools'
  at '../lib/rdf/tools.xqm';
import module namespace fuseki2 = 'http://garpix.com/semantik/app/fuseki2' 
  at '../lib/fuseki2.client.xqm';

let $rdfEndpoint as xs:anyURI :=
  xs:anyURI("http://ovz2.j40045666.px7zm.vps.myjino.ru:49408/tmp-artmotor1500")

let $папкаАнкет := 
  'C:\Users\kontu\YandexDisk-kontur32.photo\tmp\МИСИС\Анкеты 2023\'

let $списокПреподавателей :=
  parse:xlsx(file:read-binary($папкаАнкет||"Преподаватели КИК.xlsx"),"")
  /table[@label="Анкеты"]
  /row[cell[@label="Статус анкеты"]/text()]
  /cell[@label="Ф.И.О."]/normalize-space(text())

let $path := file:base-dir() || "..\example\анкета-преподавателя\"
let $paramsPath := $path || "schemas\params.json"
let $schemaPath := $path || "schemas\schema.json"

let $params := fetch:text($paramsPath)
let $schema := fetch:text($schemaPath)

for $i in $списокПреподавателей
where $i = "Мишуров Сергей Сергеевич"
let $f := file:read-binary($папкаАнкет || 'Анкеты преподавателей\' || $i || ".xlsx")

return
  rdfFile:xlsx-to-rdf($f, $schema, $params )