module namespace rdfGenContext = 'rdf/generetor/lib/context';

import module namespace rdfGenLib = 'rdf/generetor/lib'
  at 'lib.xqm';
  
  
(:~
 : Генерирует триплеты для свойств
 : @param $contex контекст данных (данные и общие параметры схемы)
 : @param $schema схема элементов
 : @param $aliases алиасы схемы
:)
declare
  %public
function rdfGenContext:localContext(
  $context as element(),
  $schema as element()
) as element()*
{
  for $property in $schema/context/_
  return
    rdfGenLib:property($context, $property, $context/aliases)
};

(:~
 : Формирует набор алиасов из схемы
 : @param $schema схема
 : @return возвращает значение 
:)
declare
  %public
function rdfGenContext:aliases(
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
function rdfGenContext:parameters(
  $data as element(data),
  $schema as element(schema)
) as element(parameters)
{
  <parameters>{
    for $parameter in $schema/context/parameters/child::*
    return
      if($parameter/value/child::*)
      then(
        let $value := rdfGenLib:propertyValue($data, $parameter)
        return
          $parameter update replace value of node . with $value
      )
      else($parameter)
    }</parameters>
};

declare
  %public
function rdfGenContext:context(
  $data as element(data),
  $schema as element(schema)
) as element()*
{
    rdfGenContext:aliases($schema),
    rdfGenContext:parameters($data, $schema)
};

(:~
 : Формирует (расширяет) контекст 
 : @param $data контекст данных (данные и общие параметры схемы)
 : @param $elements элементы для добавления в контектс
 : @return возвращает контекст 
:)
declare
  %public
function rdfGenContext:rootContext(
  $context as element(data),
  $schema as element(schema)
) as element(data)
{
  let $aliases := rdfGenContext:aliases($schema)
  let $parameters := rdfGenContext:parameters($context, $schema)
  return
    rdfGenContext:addToContext($context, ($aliases, $parameters))
};


(:~
 : Формирует (расширяет) контекст 
 : @param $data контекст данных (данные и общие параметры схемы)
 : @param $elements элементы для добавления в контектс
 : @return возвращает контекст 
:)
declare
  %public
function rdfGenContext:addToContext(
  $context as element(data),
  $elements as element()*
) as element(data)
{
  let $f :=
    function(
      $c as element(data),
      $v as element()
    )as element(data)
    {$c update insert node $v into .}
  
  return
    fold-left($elements, $context, $f)
};