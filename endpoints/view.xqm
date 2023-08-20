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
  let $itemPath := $f//node/internalPath
  
  let $scenarion :=
    for $i in file:list('/srv/nextcloud/data/' || $user || '/files/' || $domain || '/сценарии')
    where not(matches($i, '^set-')) and matches($i, 'json$')
    let $json as element(json) :=
      json:parse(
        fetch:text('/srv/nextcloud/data/' || $user || '/files/' || $domain || '/сценарии/'||$i )
      )/json
    where $json//path
    where matches($itemPath/text(), $json//path)
    return
      $json
 
  let $logRecord :=
    <node>
        <пользователь>{$user}</пользователь>
        <доменДанных>{$domain}</доменДанных>
        <файл>{$itemPath}</файл>
        <сценарий>{$scenarion}</сценарий>
        <телоЗапроса>{$f}</телоЗапроса>
      </node>
  
  let $output :=
     if($scenarion)
     then(
       try{
         set:sets(
           $scenarion,
           (),
           $itemPath/text()
         )
       }catch*{
         <error></error>
       }
     )
  return
    (
      file:write(file:base-dir() || '../var/path.xml', $logRecord),
      file:write(file:base-dir() || '../var/output.xml', $output)
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
  domain и пользователем из запроса или конфига 
  актуальный метод принудительного вызова обработки сценария
:)
declare 
  %rest:GET
  %rest:path("/trci-to-rdf/api/v01/sets/{$set}")
function view:main2($set){
  let $result := 
    if(file:exists(config:rootPath() || 'сценарии/set-' || $set || '.json'))
    then(
      <result>{
        set:main(
          config:rootPath() || 'сценарии/set-' || $set || '.json'
        )
      }</result>
       
    )
    else(
      if(file:exists(config:rootPath() || 'сценарии/' || $set || '.json'))
      then(
        let $setPath := config:rootPath() || 'сценарии/' || $set || '.json'
        let $set as element(json) := json:parse(fetch:text($setPath))/json
        return
          <result>{
            set:sets($set, ())
          }</result>
          
      )
      else(<err:SET01>сценарий {$set} не найден</err:SET01>)
    )
  return
    $result
};