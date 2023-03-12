(:~ 
  генериует шаблон схемы для trci-таблицы с использованием параметров 
:)
import module namespace parse = "http://www.iro37.ru/stasova/api/v1.1/parseXLSX" 
  at "../lib/xlsx/parseXLSX-to-TRCI.xqm";
  
import module namespace genSchema = 'rdf/generetor/schema'
  at '../lib/rdf-generator-schema.xqm';

let $dataPath := file:base-dir() || '..\example\'
let $f := file:read-binary($dataPath|| "реестр предметов\xlsx\Predmeti.xlsx")
let $table := parse:xlsx($f, "")/table

return
  genSchema:Sample($table)