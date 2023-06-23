module namespace view = "trci-to-rdf/view";

import module namespace set = 'trci-to-rdf/lib/evalute.set'
  at "../lib/evalute.set.xqm";

declare 
  %rest:POST('{$f}')
  %rest:path("/trci-to-rdf/v/file")
  %public
function view:upload($f){
  let $item := $f//node/path
  return
  (
    file:write(file:base-dir() || '../var/' || 'path.xml', $f//node/path),
    if($item)
    then(
       view:main(
         '/лицей/сценарии/set-реестр-школьников.json',
         '/srv/nextcloud/data/kontur32/files/'
       )
    )
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