module namespace rdfGenLib = 'rdf/generetor/lib';

import module namespace rdfGenElements = 'rdf/generetor/elements'
  at 'elements.xqm';

import module namespace rdfSparql = 'rdf/generetor/sparql'
  at 'sparql.xqm';

import module namespace rdfGenTools = 'rdf/generetor/tools'
  at 'tools.xqm';
  
(:~
 : Генерирует фильтр
 : @param $context контекст данных (данные и общие параметры схемы)
 : @param $schema схема содержит непосредственно значение или указание на обработчик
 : @param $aliases набор елементов, содержащих инструкции и непосредственно значения -на них могут ссылаться элементы схемы
 : @return возвращает значение 
:)
declare
  %public
function rdfGenLib:filter(
  $context as element(data),
  $schema as element(),
  $nodeName as xs:string
) as xs:boolean
{
  if($schema/filter/child::*)
  then(
    let $result := 
      rdfGenLib:propertyValue($context, $schema/filter, $context/aliases)
    return
      if($result)then(true())else(false())
  )
  else(
    if($schema/filter/text())
    then(
      let $filter := 
        <filter>
          <value>
            <xquery>{
             "matches(./" || $nodeName || "/@label/data(), '" || $schema/filter/text() || "')"
            }</xquery>
          </value>
        </filter>
      let $result := 
        rdfGenLib:propertyValue($context, $filter, $context/aliases)
      return
        if($result)then(true())else(false())
    )
    else(false())
  )
};

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
  $context as element(),
  $schema as element()
) as item()*
{
  rdfGenLib:propertyValue(
    $context,
    $schema,
    <aliases>{$schema/context/aliases/child::*}</aliases>
  )
};


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
  $context as element(),
  $schema as element(),
  $aliases as element(aliases)
) as item()*
{
  let $value :=
    if($schema/value/child::*)
    then(
      let $value := $schema/value
      let $xquery :=
        switch ($value/child::*/name())
        case 'xquery'
          return
            let $xq := $value/xquery/text()
            return
              xquery:eval($xq, map{'':$context})
        
        case 'sparql'
          return
            let $xq := rdfGenTools:getValue($value/sparql)
            let $endpoint as xs:anyURI :=
              if($value/sparql/RDF-endpoint)
              then($value/sparql/RDF-endpoint/xs:anyURI(text()))
              else($context/parameters/RDF-endpoint/xs:anyURI(text()))
            return
              rdfSparql:request($xq, $context, $endpoint)
        
        case 'parameter'
          return 
            $context/parameters/child::*[name()=$value/parameter/text()]/text()
            
        case 'alias'
          return
            let $xq := 
              $aliases/child::*[name()=$value/alias/text()]/xquery/text()
            return
              xquery:eval($xq, map{'':$context})
            
        default
          return
            let $xq := $value/xquery/text()
            return
              xquery:eval($xq, map{'':$context})
      return
       $xquery
    )
    else(
      if($schema/value)
      then($schema/value/text())
      else($context/text())
    )
   return
     $value
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
  $schema as element(),
  $aliases as element()*
) as element()
{
  let $nameSpace := $schema/nameSpace/text()
  let $localName := $schema/localName/text()
  let $value := rdfGenLib:propertyValue($context, $schema, $aliases)
  return 
    element{QName($nameSpace, $localName)}{$value}
};



(:~
 : Генерирует триплеты для свойств
 : @param $contex контекст данных (данные и общие параметры схемы)
 : @param $schema схема элементов
 : @param $aliases алиасы схемы
:)
declare
  %public
function rdfGenLib:properties(
  $context as element(),
  $schema as element()
) as element()*
{
  for $property in $schema/properties/_
  return
    rdfGenLib:property($context, $property, $context/aliases)
};

