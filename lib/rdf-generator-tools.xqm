module namespace rdfGenTools = 'rdf/generetor/tools';

(:~ 
  получает ресурс по URL или возвращает тектстовое значение элемента
 :)
declare function rdfGenTools:getValue($element as element()) as xs:string*
{
  if($element/text())
  then($element/text())
  else(
    if($element/URL)
    then(
      fetch:text(
        iri-to-uri(
          $element/URL/text()
        )
      )
    )
    else()
  )
};

(:~ 
  преобразует json-строку в map()
 :)
declare function rdfGenTools:json-to-map($json as xs:string) as map(*)
{
  map:merge(
    json:parse($json)/json/child::*/map{./name():./text()}
  )
};

(:~ 
  подставляте в json-строку схемы значения из параметров
:)
declare
  %public
function rdfGenTools:schema(
  $json as xs:string,
  $params as map(*)
) as element(schema)
{
  json:parse(rdfGenTools:replace($json, $params))/json/schema
};

(:~ 
  в строке заменяет имена параметров на значения 
:)
declare
  %public
function rdfGenTools:replace(
  $string as xs:string,
  $map as map(*)
){
  let $mapToArrays :=
    map:for-each($map, function($key, $value){[$key, $value]})
  let $f :=
    function($string, $d){replace($string, "\{\{" || $d?1 || "\}\}", $d?2)}
  return
    fold-left($mapToArrays, $string, $f)
};