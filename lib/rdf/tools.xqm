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
declare function rdfGenTools:json-to-map($json as element()) as map(*)
{
  map:merge(
    $json/child::*/map{./name():./text()}
  )
};

(:~ 
  подставляте в json-строку схемы значения из параметров
:)
declare
  %public
function rdfGenTools:schema(
  $schema as xs:string,
  $localParams as map(*)
) as element(schema)
{
  rdfGenTools:schema($schema, $localParams, map{})
};

declare
  %public
function rdfGenTools:schema(
  $schema as xs:string,
  $localParams as map(*),
  $rootParams as map(*)
) as element(schema)
{
  json:parse(
    rdfGenTools:replace(
      rdfGenTools:replace($schema, $localParams),
      $rootParams
    )
  )/json/schema
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

(:~ 
  получает ресурс 
:)
declare
  %public
function rdfGenTools:fetch(
  $path as xs:string
){
  if(matches($path, '^http'))
  then(fetch:text(iri-to-uri($path)))
  else(fetch:text($path))
};