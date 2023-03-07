module namespace rdfGenLib = 'rdf/generetor/lib';

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
  $schema as element()
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
      let $currentNodeName := $context/currentNode[last()]/text()
      let $filter := 
        <filter>
          <value>
            <xquery>{
             "matches(./" || $currentNodeName || "/@label/data(), '" || $schema/filter/text() || "')"
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
  $schema as element(),
  $aliases as element(aliases)
) as item()*
{
  let $value :=
    if($schema/value/child::*)
      then(
        let $xquery :=
          switch ($schema/value/child::*/name())
          case 'xquery'
            return
              $schema/value/xquery/text()
          case 'parameter'
            return 
              $context/parameters/child::*[name()=$schema/value/parameter/text()]/text()
          case 'alias'
            return
              $aliases/child::*[name()=$schema/value/alias/text()]/xquery/text()
          default
            return
              $schema/value/xquery/text()
        return
          xquery:eval($xquery, map{'':$context})
      )
      else(
        if($schema/value/text())
        then(
          if($schema/type/text()="resource" and not($schema/properties))
          then(
            attribute{"resource"}{$schema/value/text()}
          )
          else(
            $schema/value/text()
          )
        )
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
  $schema/properties/_/rdfGenLib:property($context, ., $context/aliases)
};

(:~
 : Формирует набор алиасов из схемы
 : @param $schema схема
 : @return возвращает значение 
:)
declare
  %public
function rdfGenLib:aliases(
  $schema as element(schema)
) as element(aliases)
{
  <aliases>{$schema/context/aliases/child::*}</aliases>
};

(:~
 : Генерирует параметры схемы (доступны в конектсе в теге parameters)
 : @param $data контекст данных (данные и общие параметры схемы)
 : @param $parameters описание параметров, в т.ч инструкции для генерации
 : @param $aliases набор елементов, содержащих инструкции и непосредственно значения -на них могут ссылаться элементы схемы
 : @return возвращает значение 
:)
declare
  %public
function rdfGenLib:parameters(
  $data as element(data),
  $schema as element(schema)
) as element(parameters)
{
  let $aliases := <aliases>{$schema/context/aliases/child::*}</aliases>
  return
    <parameters>{
      for $parameter in $schema/context/parameters/child::*
      return
        if($parameter/value/child::*)
        then(
          let $value := rdfGenLib:propertyValue($data, $parameter, $aliases)
          return
            $parameter update replace value of node . with $value
        )
        else($parameter)
      }</parameters>
};

(:~
 : Формирует (расширяет) контекст 
 : @param $data контекст данных (данные и общие параметры схемы)
 : @param $elements элементы для добавления в контектс
 : @return возвращает контекст 
:)
declare
  %public
function rdfGenLib:buidRootContext(
  $context as element(data),
  $schema as element(schema)
) as element(data)
{
  let $aliases :=
    rdfGenLib:aliases($schema)
  let $parameters :=
    rdfGenLib:parameters($context, $schema)
  return
    rdfGenLib:buildContext($context, ($aliases, $parameters))
};


(:~
 : Формирует (расширяет) контекст 
 : @param $data контекст данных (данные и общие параметры схемы)
 : @param $elements элементы для добавления в контектс
 : @return возвращает контекст 
:)
declare
  %public
function rdfGenLib:buildContext(
  $context as element(data),
  $elements as element()*
) as element(data)
{
  let $f :=
    function($c as element(data), $v as element()){$c update insert node $v into .}
  return
    fold-left($elements, $context, $f)
};