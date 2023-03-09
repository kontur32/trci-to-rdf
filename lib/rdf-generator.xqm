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
  let $rows := rdfGen:rows($context, $schema/row)
  let $properties := rdfGenLib:properties($context, $schema)
  return
    if($schema/type = "resource")
    then(
      rdfGenElements:description($context, $schema, ($properties, $rows))
    )
    else($rows)
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

declare function rdfGen:trci-to-rdf(
  $context as element(data),
  $params
) as element(Q{http://www.w3.org/1999/02/22-rdf-syntax-ns#}RDF)
{
  let $result := 
    for $table in $context/file/table
    let $schema :=
      rdfGenTools:schema(genSchema:Sample($table), $params)
    let $localContext :=
      rdfGenLib:buidRootContext($context, $schema) 
    let $body :=
      rdfGen:tables($localContext, $schema/table)
    return
      $body
  return
    rdfGenElements:RDF($result)
};