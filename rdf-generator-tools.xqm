module namespace rdfGenTools = 'rdf/generetor/tools';

declare function rdfGenTools:json-to-map($json as xs:string) as map(*)
{
  map:merge(
    json:parse($json)/json/child::*/map{./name():./text()}
  )
};

declare function rdfGenTools:schema($json as xs:string, $params) as element(schema)
{
  json:parse(rdfGenTools:replace($json, $params))/json/schema
};

declare function rdfGenTools:replace($string, $map){
  fold-left(
    map:for-each($map, function($key, $value){map{$key : $value}}),
    $string, 
    function($string, $d){
       replace(
        $string,
        "\{\{" || map:keys($d)[1] || "\}\}",
        replace(serialize(map:get($d, map:keys($d)[1])), '\\', '\\\\') 
      ) 
    }
  )
};