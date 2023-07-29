module namespace view = "trci-to-rdf/view";

import module namespace set = 'trci-to-rdf/lib/evalute.set'
  at "../lib/evalute.set.xqm";

import module namespace config = 'trci-to-rdf/lib/config'
  at "../lib/config.xqm";

(:
  метод для обновления файла в RDF-хранилище для вэбхука nextcloud  
:)
declare 
  %rest:POST('{$f}')
  %rest:path("/trci-to-rdf/v/file/{$user}/{$domain}")
  %public
function view:upload($f, $user, $domain){
  let $item := $f//node/path
  let $map := 
    fetch:xml(
      '/srv/nextcloud/data/' || $user || '/files/' || $domain || '/сценарии/map.xml'
    )
  let $sc :=
    $map//node['/' || $user || '/files' || path/text()=$item/text()]/sc/text()
  let $output :=
    <node>
        <item>{$item}</item>
        <sc>{$sc}</sc>
        <user>{$user}</user>
        <dir>{$domain}</dir>
        <f>{$f}</f>
        <map>{$map}</map>
      </node>
  return
  (
    file:write(file:base-dir() || '../var/path.xml', $output),
    file:write(file:base-dir() || '../var/output.xml', view:main($sc, '/srv/nextcloud/data/'|| $user || '/files')),
    $output,
    if($sc)then(view:main($sc, '/srv/nextcloud/data/'|| $user || '/files'))
  )
};


declare 
  %rest:POST('{$f}')
  %rest:path("/trci-to-rdf/v/file")
  %public
function view:upload($f){
  let $item := $f//node/path
  let $sc :=
    fetch:xml(
      '/srv/nextcloud/data/kontur32/files/лицей/сценарии/map.xml'
    )//node['/kontur32/files' || path/text()=$item/text()]/sc/text()
    
  return
  (
    file:write(
      file:base-dir() || '../var/path.xml',
      <node>
        {$item}
        <sc>{$sc}</sc>
      </node>
    ),
    if($sc)then(view:main($sc, '/srv/nextcloud/data/kontur32/files'))
  )
};


(:
  старый вызов запуска обработки сценария 
  используется в вызове метода автообновления - отрефакторить
:)
declare 
  %rest:GET
  %rest:query-param('path', '{$path}')
  %rest:query-param('_root-path', '{$root-path}', '/srv/nextcloud/data/kontur32/files/')
  %rest:path("/trci-to-rdf/v")
function view:main($path, $root-path){
  <result>{
    set:main(
       $root-path || $path
     )
  }</result>
};


(:
  без параметров domain и с пользователем корневым путем из конфига 
  актуальный метод вызова обработки сценария
  надо привязать к методу автообработки из вэбхука nextcloud
:)
declare 
  %rest:GET
  %rest:path("/trci-to-rdf/api/v01/sets/{$set}")
function view:main2($set){
  let $result := 
    if(file:exists(config:rootPath() || 'сценарии/set-' || $set || '.json'))
    then(
       set:main(
         config:rootPath() || 'сценарии/set-' || $set || '.json'
       )
    )
    else(
      set:sets(
         config:rootPath() || 'сценарии/' || $set || '.json', ()
       )
    )
  return
    <result>{$result}</result>
};


(:
  актуальный метод вызова обработки сценария
  надо привязать к методу автообработки из вэбхука nextcloud
:)
declare 
  %rest:GET
  %rest:query-param('_root-path', '{$root-path}', '/srv/nextcloud/data/kontur32/files/localhost')
  %rest:path("/trci-to-rdf/api/v01/domains/{$domain}/sets/{$set}")
function view:main($root-path, $domain, $set){
  <result>{
    set:main(
       $root-path || 'сценарии/set-' || $set || '.json'
     )
  }</result>
};