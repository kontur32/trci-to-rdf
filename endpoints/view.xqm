module namespace view = "trci-to-rdf/view";

import module namespace set = 'trci-to-rdf/lib/evalute.set'
  at "../lib/evalute.set.xqm";

declare 
  %rest:POST('{$f}')
  %rest:path("/trci-to-rdf/v/file")
  %public
function view:upload($f){
  let $item := $f//node/path
  let $sc :=
    fetch:xml(
      '/srv/nextcloud/data/kontur32/files/лицей/сценарии/map.xml'
    )//node[path/text()=$item/text()]/sc/text()
    
  return
  (
    file:write(
      file:base-dir() || '../var/' || 'path.xml',
      <node>
        {$f//node/path}
        <sc>{$sc}</sc>
      </node>
    ),
    if($sc)then(view:main($sc, ''))
  )
};

declare 
  %rest:GET
  %rest:query-param('path', '{$path}')
  %rest:query-param('root-path', '{$root-path}', '/srv/nextcloud/data/kontur32/files/')
  %rest:path("/trci-to-rdf/v")
function view:main($path, $root-path){
  <result>{
    set:main(
       $root-path || $path
     )
  }</result>
};