module namespace rdfGen = 'rdf/generetor';

import module namespace rdfGenElements = 'rdf/generetor/elements'
  at 'rdf-generator-elements.xqm';

import module namespace rdfGenLib = 'rdf/generetor/lib'
  at 'rdf-generator-lib.xqm';
  
import module namespace rdfGenTools = 'rdf/generetor/tools'
  at 'rdf-generator-tools.xqm';

import module namespace genSchema = 'rdf/generetor/schema'
  at 'rdf-generator-schema.xqm';

(:~
 : Генерирует RDF ячейки 
 : @param $context контекст данных (данные и общие параметры схемы)
 : @param $schema схема для обработки ячеек
 : @return возвращает набор триплетов RDF/XML 
:)
declare
  %private
function rdfGen:cell(
  $context as element(data),
  $schema as element(properties)
) as element()*
{
  for $property in $schema/_[type="property" or empty(type)]
  
  let $filter := rdfGenLib:filter($context, $property)
  where $filter 
  
  let $cell :=  $context/cell[$filter]
  where $cell/text()
  
  return
    rdfGenLib:property($cell, $property, $context/aliases),
    
(:-- properties --:)  
  for $property in $schema/_[type="properties"]  
  let $filter := rdfGenLib:filter($context, $property)
  where $filter  
  for $cell in $context/cell[$filter]
  where $cell/text()  
  let $cellProperties := 
    $property/properties/_/rdfGenLib:property($cell, ., $context/aliases)
  return
    $cellProperties,
  
  (:-- resource --:)  
  for $property in $schema/_[type="resource"]  
  let $filter := rdfGenLib:filter($context, $property)
  where $filter 
  for $cell in $context/cell[$filter]
  where $cell/text()
  
  let $cellRootProperty :=
    $property/rdfGenLib:property(<data/>, ., $context/aliases)
  let $cellProperties := 
    $property/properties/_/rdfGenLib:property($cell, ., $context/aliases)
  let $cellDescription :=
    rdfGenElements:description($context, $schema, $cellProperties)
  return
    $cellRootProperty update insert node $cellDescription into .
};

(:~
 : Генерирует RDF ячеек строки таблицы 
 : @param $context контекст данных (данные и общие параметры схемы)
 : @param $schema схема для обработки ячеек
 : @return возвращает набор триплетов RDF/XML 
:)
declare
  %private
function rdfGen:cells(
  $context as element(data),
  $schema as element(cell)
) as element()*
{
  for $cell in $context/row/cell
  let $localContext := rdfGenLib:buildContext($context, (<currentNode>cell</currentNode>, $cell))
  return
    rdfGen:cell($localContext, $schema/properties)
};


(:~
 : Генерирует RDF из строк таблицы 
 : @param $context контекст данных (данные и общие параметры схемы)
 : @param $schema схема для обработки строк
 : @return возвращает набор триплетов RDF/XML 
:)
declare
  %private
function rdfGen:row(
  $context as element(data),
  $schema as element(row)
) as element()*
{
  
  let $body := rdfGen:cells($context, $schema/cell)
  let $properties := rdfGenLib:properties($context, $schema)
  let $localProperties := rdfGenLib:context($context, $schema)
  return
    if($schema/type = "resource")
    then(
      let $rowRootPropery :=
        rdfGenLib:property(<data/>, $schema, $context/aliases)
      
      let $localContext :=
        rdfGenLib:buildContext(
          $context, <context>{$localProperties}</context>
        )
      
      let $rowDescription :=
        rdfGenElements:description($localContext, $schema, ($properties, $body))
      
      return
        $rowRootPropery update insert node $rowDescription into .
    )
    else($body)
};

(:~
 : Генерирует RDF из строк таблицы 
 : @param $context контекст данных (данные и общие параметры схемы)
 : @param $schema схема для обработки строк
 : @return возвращает набор триплетов RDF/XML 
:)
declare
  %private
function rdfGen:rows(
  $context as element(data),
  $schema as element(row)
) as element()*
{
  for $row in $context/table/row
  let $localContext :=
    rdfGenLib:buildContext(
      $context, (<currentNode>row</currentNode>, $row)
    )
  let $filter := rdfGenLib:filter($localContext, $schema)
  where $filter 
  return
    rdfGen:row($localContext, $schema)
};


(:~
 : Генерирует RDF из таблицы 
 : @param $context контекст данных (данные и общие параметры схемы)
 : @param $schema схема для обработки таблицы
 : @return возвращает набор триплетов RDF/XML 
:)
declare
  %private
function rdfGen:table(
  $context as element(data),
  $schema as element(table)
) as element()*
{
  let $body := rdfGen:rows($context, $schema/row)
  let $properties := rdfGenLib:properties($context, $schema)
  let $localProperties := rdfGenLib:context($context, $schema)
  let $localContext :=
        rdfGenLib:buildContext(
          $context, <context>{$localProperties}</context>
        )
  return
    if($schema/type = "resource")
    then(
      rdfGenElements:description($localContext, $schema, ($properties, $body))
    )
    else($body)
};

(:~
 : Генерирует RDF из таблиц 
 : @param $context контекст данных (данные и общие параметры схемы)
 : @param $schema схема для обработки таблицы
 : @return возвращает набор триплетов RDF/XML 
:)
declare
  %private
function rdfGen:tables(
  $context as element(data),
  $schema as element(table)
) as element()*
{
  for $table in $context/file/table
  let $localContext := 
    rdfGenLib:buildContext(
      $context,
      (<currentNode>table</currentNode>, $table)
    )
  let $filter := rdfGenLib:filter($localContext, $schema)
  where $filter 
  return
    rdfGen:table($localContext, $schema)
};

declare function rdfGen:description(
  $context as element(data),
  $schema as element(schema)
) as element()*
{
  let $localContext :=
    rdfGenLib:buidRootContext($context, $schema) 
  let $body := 
    rdfGen:tables($localContext, $schema/table)
  return
    $body
};

(:~ 
    преобразует trci в RDF-граф на основе автоматически сгенерированной схемы
:)
declare function rdfGen:auto-trci-to-rdf(
  $file as element(file)
) as element(Q{http://www.w3.org/1999/02/22-rdf-syntax-ns#}RDF)
{
  let $params :=
    map{
      "домен.онтология": "http://example.com/semantic/онтология/",
      "домен.схема": "http://example.com/semantic/schema/",
      "домен.сущности": "http://example.com/semantic/сущности/",
      "домен.схема.префикс": "example",
      "xmlns.rdf": "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
      "class.table": "Таблица",
      "class.row": "Строка"
    }
  return
    rdfGen:auto-trci-to-rdf($file, $params)
};

(:~ 
    преобразует trci в RDF-граф на основе автоматически сгенерированной схемы
:)
declare function rdfGen:auto-trci-to-rdf(
  $file as element(file),
  $params as map(*)
) as element(Q{http://www.w3.org/1999/02/22-rdf-syntax-ns#}RDF)
{
  let $result := 
    for $table in $file/table
    let $schema :=
      rdfGenTools:schema(genSchema:Sample($table), $params)
    let $localContext :=
      rdfGenLib:buidRootContext(<data>{$file}</data>, $schema) 
    let $body :=
      rdfGen:tables($localContext, $schema/table)
    return
      $body
  return
    rdfGenElements:RDF($result)
};


(:~ 
    преобразует trci в RDF-граф на основе схемы
:)
declare
  %public
function rdfGen:file-to-rdf(
  $file as element(file),
  $schemaFile as element(schema)
) as element(Q{http://www.w3.org/1999/02/22-rdf-syntax-ns#}RDF)
{
 let $descriptions :=
    for $i in $schemaFile/_
    let $fetchTableParams :=
      fetch:text(iri-to-uri($i/parameters/text()))
    let $tableParams :=
      rdfGenTools:json-to-map($fetchTableParams)
    let $fetchTableSchema :=
      fetch:text(iri-to-uri($i/URL/text()))
    let $tableSchema :=
      rdfGenTools:schema($fetchTableSchema, $tableParams)
    let $context := <data>{$file}</data>
    return
      rdfGen:description($context, $tableSchema)  
  return
    rdfGenElements:RDF($descriptions)
};