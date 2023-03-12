(:~ 
  генериует RDF из для trci-файла (несколько таблиц) с использованием параметров 
:)
import module namespace parse = "http://www.iro37.ru/stasova/api/v1.1/parseXLSX" 
  at "../lib/xlsx/parseXLSX-to-TRCI.xqm";
  
import module namespace rdfGen = 'rdf/generetor'
  at '../lib/rdf-generator.xqm';
import module namespace rdfGenTools = 'rdf/generetor/tools'
  at '../lib/rdf-generator-tools.xqm';
import module namespace fuseki2 = 'http://garpix.com/semantik/app/fuseki2' 
  at '../lib/client.fuseki2.xqm';

let $rdfEndpoint as xs:anyURI :=
  xs:anyURI("http://ovz2.j40045666.px7zm.vps.myjino.ru:49408/tmp-artmotor1500")
let $path :=  
    'http://a.roz37.ru/lipers/семантический.контракт/мисис/анкета-преподавателя/'
let $папкаАнкет := 
  'C:\Users\kontu\YandexDisk-kontur32.photo\tmp\МИСИС\Анкеты 2023\'

let $списокПреподавателей :=
  parse:xlsx(file:read-binary($папкаАнкет||"Преподаватели КИК.xlsx"),"")
  /table[@label="Анкеты"]
  /row[cell[@label="Статус анкеты"]/text()]
  /cell[@label="Ф.И.О."]/normalize-space(text())

let $paramsPath := $path || 'params.json'
let $schemaPath := $path || 'schema.json'

let $params := rdfGenTools:json-to-map(fetch:text(iri-to-uri($paramsPath)))
let $schemaFile :=rdfGenTools:schema(fetch:text(iri-to-uri($schemaPath)), $params)

for $i in $списокПреподавателей
where $i = "Мишуров Сергей Сергеевич"
let $f := file:read-binary($папкаАнкет || 'Анкеты преподавателей\' || $i || ".xlsx")
let $file := parse:xlsx($f, "Анкетные данные")
let $rdf := try{rdfGen:file-to-rdf($file, $schemaFile)}catch*{false()}
let $graphName as xs:anyURI := 
  xs:anyURI("http://misis.roz37.ru/cv/" || replace($i, '\s', '-') )
return
  ($rdf, $graphName, $rdfEndpoint)