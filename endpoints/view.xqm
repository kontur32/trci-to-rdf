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
  let $sc := $map//node[matches($item/text(), path/text())]/sc/text()
  let $logRecord :=
    <node>
        <файл>{$item}</файл>
        <сценарий>{$sc}</сценарий>
        <пользователь>{$user}</пользователь>
        <доменДанных>{$domain}</доменДанных>
        <телоЗапроса>{$f}</телоЗапроса>
        {$map}
      </node>
  let $result :=
     if($sc)
     then(
       set:main(
         '/srv/nextcloud/data/'|| $user || '/files' || $sc,
         $item/text()
       )
     )
  return
    (
      file:write(file:base-dir() || '../var/path.xml', $logRecord),
      file:write(file:base-dir() || '../var/output.xml', $result)
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