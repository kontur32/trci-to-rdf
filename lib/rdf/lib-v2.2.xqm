module namespace rdfGenLib = 'rdf/generetor/lib';

import module namespace rdfGenElements = 'rdf/generetor/elements'
  at 'elements-v2.2.xqm';

import module namespace rdfSparql = 'rdf/generetor/sparql'
  at 'sparql-v2.2.xqm';

import module namespace rdfGenTools = 'rdf/generetor/tools'
  at 'tools.xqm';
  

(:~
 : Генерирует значение элемента
 : @param $data контекст данных (данные и общие параметры схемы)
 : @param $schema схема содержит непосредственно значение или указание на обработчик
 : @param $aliases набор елементов, содержащих инструкции и непосредственно значения -на них могут ссылаться элементы схемы
 : @return возвращает значение 
:)
declare
  %public
function rdfGenLib:propertyValue(
  $context as element(context),
  $schema as element()
) as item()*
{
  let $result :=
    if($schema/compute/child::*)
    then(
      let $value := $schema/compute
      let $xquery :=
        switch ($value/child::*/name())
        case 'xquery'
          return
            let $xq := 
              if($value/xquery/child::*)
              then($value/xquery/child::*/text())
              else($value/xquery/text())
            return
              fold-left(
                ($xq),
                $context/data/child::*,
                function($c, $p){xquery:eval($p, map{'':$c})}
              )
        
        case 'sparql'
          return
            let $sparql := rdfGenTools:getValue($value/sparql)
            let $endpoint as xs:anyURI :=
              if($value/sparql/RDF-endpoint)
              then($value/sparql/RDF-endpoint/xs:anyURI(text()))
              else($context/RDF-endpoint/xs:anyURI(text()))
            return
              rdfSparql:request($sparql, $context, $endpoint)
        
        case "include"
          return
             rdfGenLib:p($context, rdfGenTools:schemaGet($value/include))
        
        default
          return
            let $xq := $value/xquery/text()
            return
              xquery:eval($xq, map{'':$context})
      return
       $xquery
    )
    else($context/text())
   return
     $result
};

(:~
 : Генерирует триплет для свойства
 : @param $contex контекст данных (данные и общие параметры схемы)
 : @param $schema схема элементов
 : @param $aliases алиасы схемы
:)
declare
  %public
function rdfGenLib:property(
  $context as element(),
  $schema as element()
) as element()
{
  let $nameSpace := $schema/QName/_[1]/text()
  let $localName := $schema/QName/_[2]/text()
  let $value := rdfGenLib:propertyValue($context, $schema)
  return 
    element{QName($nameSpace, $localName)}{$value}
};

declare
  %public
function rdfGenLib:content(
  $context as element(context),
  $schema as element(_)
){
  for $i in $schema/constructor/content/child::*
  return
    if($i/name()="compute")
    then(
       if($i/child::*)
       then(
         rdfGenLib:propertyValue($context, $schema/constructor/content)
       )
       else($i/text())
    )
    else(rdfGenLib:p($context, $i))
};

declare
  %public
function rdfGenLib:container(
  $context as element(context),
  $schema as element(_)
){
  let $schemaContainer := $schema/constructor/container
  return
    switch($schemaContainer/type/text())
    case "property"
      return rdfGenLib:property($context, $schemaContainer)
    case "resource"
      return rdfGenLib:property($context, $schemaContainer)
    case "description"
      return rdfGenElements:description($context, $schemaContainer)
    case "none"
      return ()
    default 
      return ()
};

declare
  %public
function rdfGenLib:p(
  $context as element(context),
  $schemaRoot as element(_)*
){
  
  for $schema in $schemaRoot
  
  let $localParams :=
    for $i in $schema/context/child::*
    return
      if($i/child::*)
      then(element{$i/name()}{rdfGenLib:propertyValue($context, $i)})
      else($i)
      
  let $localContext :=
    fold-left(
        $localParams,
        $context,
        function($c, $p){
          if($c/child::*/name()=$p/name())
          then($c update replace node ./child::*[name()=$p/name()] with $p)
          else($c update insert node $p into .)
        }
      )
  
  for $i in $localContext/data/child::*  
  let $lc :=
    $localContext update replace node ./data with <data>{$i}</data>
  let $container := rdfGenLib:container($lc, $schema)
  let $content := rdfGenLib:content($lc, $schema)
  where $content
  return
    if($container)
    then(
      if($schema/constructor/container/type[text()="resource"])
      then(
        $container update insert node rdfGenElements:elementRecource($content) into .
      )
      else($container update insert node $content into .)
    )
    else($content)
};
