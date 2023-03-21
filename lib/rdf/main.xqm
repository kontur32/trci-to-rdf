module namespace rdfGen = 'rdf/generetor';

import module namespace rdfGenElements = 'rdf/generetor/elements'
  at 'elements.xqm';

import module namespace rdfGenLib = 'rdf/generetor/lib'
  at 'lib.xqm';
  
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
  %public
function rdfGen:tables(
  $trci as element(file),
  $schema as element(schema)
) as element()*
{
  let $localContext := rdfGenLib:buidRootContext(<data>{$trci}</data>, $schema)
  
  for $table in $localContext/file/table
  let $localTableContext := 
    rdfGenLib:buildContext(
      $localContext,
      (<currentNode>table</currentNode>, $table)
    )
  let $filter := rdfGenLib:filter($localTableContext, $schema/table)
  where $filter 
  return
    rdfGen:table($localTableContext, $schema/table)
};