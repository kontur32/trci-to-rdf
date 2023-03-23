module namespace rdfGen = 'rdf/generetor';

import module namespace rdfGenElements = 'rdf/generetor/elements'
  at 'elements.xqm';

import module namespace rdfGenLib = 'rdf/generetor/lib'
  at 'lib.xqm';

import module namespace rdfGenContext = 'rdf/generetor/lib/context'
  at 'context.xqm';
  
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
  $schema as element(cell)
) as element()*
{
  for $property in $schema/_
  let $cell :=  $context/cell
  let $filter := rdfGenLib:filter($context, $property, $schema/name())
  where $filter and $context/cell/text()

  return
    switch($property/type/text())
    case("property")
      return
        rdfGenLib:property($cell, $property, $context/aliases)
    case("properties")
      return
        let $cellProperties := 
          $property/properties/_/rdfGenLib:property($context, ., $context/aliases)
        return
          $cellProperties
    case("resource")
      return
        let $cellRootProperty :=
          $property/rdfGenLib:property($cell, ., $context/aliases)
        let $cellProperties := 
          $property/properties/_/rdfGenLib:property($cell, ., $context/aliases)
        let $cellDescription :=
          rdfGenElements:description($context, $property, $cellProperties)
        return
          $cellRootProperty update insert node $cellDescription into .
    default return
      rdfGenLib:property($cell, $property, $context/aliases)
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
  let $localContext := rdfGenContext:addToContext($context, $cell)
  return
    rdfGen:cell($localContext, $schema)
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
  return
    if($schema/type = "resource")
    then(
      let $properties := rdfGenLib:properties($context, $schema)
      let $rowRootPropery :=
        rdfGenLib:property(<data/>, $schema, $context/aliases)
      let $rowDescription :=
        rdfGenElements:description($context, $schema, ($properties, $body))
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
  let $localContext := rdfGenContext:addToContext($context, $row)
  let $filter := rdfGenLib:filter($localContext, $schema, $schema/name())
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
  return
    if($schema/type = "resource")
    then(
      rdfGenElements:description($context, $schema, ($properties, $body))
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
  $context as element(data),
  $schema as element()
) as element()*
{
  for $node in $context/file/table
  let $localContext := rdfGenContext:addToContext($context, $node)
  let $filter := rdfGenLib:filter($localContext, $schema, $schema/name())    
  where $filter 
  return
    rdfGen:table($localContext, $schema)
};