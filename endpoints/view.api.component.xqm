module namespace view = "trci-to-rdf/view/api/component";

import module namespace rdfSparql = "rdf/generetor/sparql"
  at "../lib/rdf/2.3/sparql.xqm";

declare 
  %rest:GET
  %rest:query-param('root-path', '{$root-path}', '/srv/nextcloud/data/kontur32/files/')
  %rest:path("/trci-to-rdf/api/v01/components/{$component}")
function view:main($root-path, $component){
  let $запрос := 
    fetch:text(
      $root-path || "/компоненты/" || $component || '/данные.rq'
    )
  
  let $context :=
    <context>{
      for $i in request:parameter-names()
      return
        element{$i}{request:parameter($i)}
    }</context>
  
  let $data :=
    rdfSparql:request(
      $запрос,
      $context,
     xs:anyURI("http://localhost:3030/kik.misis.ru/sparql")
   )//bindings/_
  let $xq := 
    fetch:text(
      $root-path || "/компоненты/" || $component || '/обработка.xq'
    )
  let $result :=
    if($xq)
    then(xquery:eval($xq, map{'context':$context, 'data':$data}))
    else($data)
    
  return
    $result
};