module namespace rdfGen = 'rdf/generetor';

declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";

(:~
 : Генерирует фильтр
 : @param $context контекст данных (данные и общие параметры схемы)
 : @param $schema схема содержит непосредственно значение или указание на обработчик
 : @param $aliases набор елементов, содержащих инструкции и непосредственно значения -на них могут ссылаться элементы схемы
 : @return возвращает значение 
:)
declare
  %private
function rdfGen:filter(
  $context as element(data),
  $schema as element(),
  $aliases as element(aliases)
) as xs:boolean
{
  if($schema/filter)
  then(
    let $result := rdfGen:propertyValue($context, $schema/filter, $aliases)
    return
      if($result)then(true())else(false())
  )
  else(true())
};


(:~
 : Генерирует значение элемента
 : @param $data контекст данных (данные и общие параметры схемы)
 : @param $schema схема содержит непосредственно значение или указание на обработчик
 : @param $aliases набор елементов, содержащих инструкции и непосредственно значения -на них могут ссылаться элементы схемы
 : @return возвращает значение 
:)
declare
  %private
function rdfGen:propertyValue(
  $context as element(data),
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
        then($schema/value/text())
        else($context/text())
      )
   return
     $value
};


(:~
 : Формирует набор алиасов из схемы
 : @param $schema схема
 : @return возвращает значение 
:)
declare
  %public
function rdfGen:aliases(
  $schema as element(schema)
) as element(aliases)
{
  <aliases>{$schema/aliases/child::*}</aliases>
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
function rdfGen:parameters(
  $data as element(data),
  $parameters as element(parameters),
  $aliases as element(aliases)
) as element(parameters)
{
  <parameters>{
    for $parameter in $parameters/child::*
    return
      if($parameter/value/child::*)
      then(
        let $value := rdfGen:propertyValue($data, $parameter, $aliases)
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
function rdfGen:buidContext(
  $contex as element(data),
  $elements as element()*
) as element(data)
{
  let $f :=
    function($c as element(data), $v as element()){$c update insert node $v into .}
  return
    fold-left($elements, $contex, $f)
};

(:~
 : Генерирует элемент rdf:about
 : @param $about контекст данных (данные и общие параметры схемы)
 : @param $elements элементы для добавления в контектс
 : @return возвращает контекст 
:)
declare
  %public
function rdfGen:buidElementAbout(
  $context as element(data),
  $schema as element()*,
  $aliases as element(aliases)
) as attribute(rdf:about)*
{
  if($schema)
  then(
    attribute{'rdf:about'}{rdfGen:propertyValue($context, $schema, $aliases)}
  )
  else()
};

(:~
 : Генерирует элемент rdfGen:Description
 : @param $about контекст данных (данные и общие параметры схемы)
 : @param $elements элементы для добавления в контектс
 : @return возвращает контекст 
:)
declare
  %public
function rdfGen:buidElementDescription(
  $about as attribute(rdf:about)*,
  $elements as element()*
) as element(rdf:Description)
{
  element{'rdf:Description'}{
    if($about)then($about)else(),
    $elements
  }
};

(:~
 : Генерирует RDF из строк таблицы 
 : @param $context контекст данных (данные и общие параметры схемы)
 : @param $schema схема для обработки строк
 : @param $aliases набор елементов, содержащих инструкции и непосредственно значения
 : @return возвращает набор триплетов RDF/XML 
:)
declare
  %private
function rdfGen:row(
  $context as element(data),
  $schema as element(row),
  $aliases as element(aliases)
) as element()*
{
  let $body := $context/row
  return
    if($schema/type = "subject")
    then(
      rdfGen:buidElementDescription(
        rdfGen:buidElementAbout($context, $schema/about, $aliases),
       $body
      )
    )
    else($body)
};

(:~
 : Генерирует RDF из строк таблицы 
 : @param $context контекст данных (данные и общие параметры схемы)
 : @param $schema схема для обработки строк
 : @param $aliases набор елементов, содержащих инструкции и непосредственно значения
 : @return возвращает набор триплетов RDF/XML 
:)
declare
  %private
function rdfGen:rows(
  $context as element(data),
  $schema as element(row),
  $aliases as element(aliases)
) as element()*
{
  for $row in $context/table/row
  let $localContext := rdfGen:buidContext($context, $row)
  let $filter := rdfGen:filter($localContext, $schema, $aliases)
  where $filter 
  return
    rdfGen:row($localContext, $schema, $aliases)
};


(:~
 : Генерирует RDF из таблицы 
 : @param $context контекст данных (данные и общие параметры схемы)
 : @param $schema схема для обработки таблицы
 : @param $aliases набор елементов, содержащих инструкции и непосредственно значения
 : @return возвращает набор триплетов RDF/XML 
:)
declare
  %private
function rdfGen:table(
  $context as element(data),
  $schema as element(table),
  $aliases as element(aliases)
) as element()*
{
  let $body := rdfGen:rows($context, $schema/row, $aliases)
  return
    if($schema/type = "subject")
    then(
      rdfGen:buidElementDescription(
        rdfGen:buidElementAbout($context, $schema/about, $aliases),
        $body
      )
    )
    else($body)
};

(:~
 : Генерирует RDF из таблиц 
 : @param $context контекст данных (данные и общие параметры схемы)
 : @param $schema схема для обработки таблицы
 : @param $aliases набор елементов, содержащих инструкции и непосредственно значения
 : @return возвращает набор триплетов RDF/XML 
:)
declare
  %private
function rdfGen:tables(
  $context as element(data),
  $schema as element(table),
  $aliases as element(aliases)
) as element()*
{
  for $tableData in $context/file/table
  let $localContext := rdfGen:buidContext($context, $tableData)
  let $filter := rdfGen:filter($localContext, $schema, $aliases)
  where $filter 
  return
    rdfGen:table($localContext, $schema, $aliases)
};

declare function rdfGen:rdf(
  $context as element(data),
  $schema as element(schema)
) as element(rdf:RDF)
{
  let $aliases := rdfGen:aliases($schema)
  let $parameters := rdfGen:parameters($context, $schema/parameters, $aliases)
  
  let $localContext := rdfGen:buidContext($context, $parameters)
  let $body := rdfGen:tables($localContext, $schema/table, $aliases)
  return
    <rdf:RDF>{$body}</rdf:RDF>
};