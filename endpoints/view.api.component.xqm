module namespace view = "trci-to-rdf/view/api/component";

import module namespace rdfSparql = "rdf/generetor/sparql/2.3"
  at "../lib/rdf/2.3/sparql.xqm";
  
import module namespace config = 'trci-to-rdf/lib/config'
  at "../lib/config.xqm";
  
(:
  вызов метода запуска компонента без параметра "domains" 
  и с пользователем и корневым путем из конфига
:)
declare 
  %rest:GET
  %rest:path("/trci-to-rdf/api/v01/components/{$component}")
function view:main2($component){
    view:main(
      config:param('rdfHost'),
      config:rootPath(),
      config:dataDomain(),
      $component
    )
};

(:
  вызов метода выполнения компонента по изввлечению данных из базы
:)
declare 
  %rest:GET
  %rest:query-param('_rdf-host', '{$rdf-host}', 'http://fuseki:3030/')
  %rest:query-param('_root-path', '{$root-path}', '/srv/nextcloud/data/kontur32/files/localhost')
  %rest:path("/trci-to-rdf/api/v01/domains/{$domain}/components/{$component}")
function view:main($rdf-host, $root-path, $domain, $component){
  let $path := $root-path || "/компоненты/" || $component 
  let $запрос := 
    fetch:text(
      $path || '/данные.rq'
    )
  
  let $context :=
    <context>{
      for $i in request:parameter-names()
      where not(starts-with($i, '_'))
      return
        element{$i}{request:parameter($i)}
    }</context>
  
  let $data :=
    rdfSparql:request(
      $запрос,
      $context,
     xs:anyURI($rdf-host || $domain || "/sparql")
   )//bindings/_
  
  let $xq := 
    if(file:exists($path || '/обработка.xq'))
    then(
      fetch:text($path || '/обработка.xq')
    )
    else(())
      
  let $result :=
    if($xq)
    then(xquery:eval($xq, map{'context':$context, 'data':$data}))
    else(<data>{$data}</data>)
    
  return
    $result
};