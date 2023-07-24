module namespace rdfGenTools = 'rdf/generetor/tools/2.4';


(:~ 
  по заданному URL фетчит схему
:)
declare function rdfGenTools:schemaFetch($path as xs:string) as element(json)
{
  rdfGenTools:jsonFetch($path)
};

(:~ 
  по заданному URL фетчит json в дерево
:)
declare function rdfGenTools:jsonFetch($path as xs:string) as element(json)
{
  json:parse(rdfGenTools:fetch($path))/json
};

(:~ 
  получает ресурс по URL или возвращает тектстовое значение элемента
:)
declare function rdfGenTools:getValue($element as element()) as xs:string*
{
  if($element/text())
  then($element/text())
  else(
    if($element/URI)
    then(
      if(matches($element/URI/text(), "^http"))
      then(
        fetch:text(
          iri-to-uri(
            $element/URI/text()
          )
        )
      )
      else(
        fetch:text($element/URI/text())
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
  $settings as map(*)*
) as element(schema)
{
  let $str :=
    fold-left(
      $settings,
      $schema,
      function($string, $params){rdfGenTools:replace($string, $params)}
    )
  return
    json:parse($str)/json/schema
  
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
) as xs:string
{
  if(matches($path, '^http'))
  then(fetch:text(iri-to-uri($path)))
  else(fetch:text($path))
};