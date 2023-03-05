(:~ 
  генериует шаблон схемы для trci-таблицы с использованием параметров 
:)

import module namespace genSchema = 'rdf/generetor/schema'
  at '../lib/rdf-generator-schema.xqm';

let $table := 
  fetch:xml(file:base-dir() || "..\example\TRCI\trci-example.xml")/file/table[1]

return
  genSchema:Sample($table)