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
  let $itemPath := 
    if($f//object_name)then($f//object_name)else($f//node/internalPath)
  let $rootScenarioPath := '/srv/nextcloud/data/' || $user || '/files/' || $domain || '/сценарии'
  let $scenarion :=
    for $i in file:list($rootScenarioPath)
    where not(matches($i, '^set-')) and matches($i, 'json$')
    let $json as element(json) := json:parse(fetch:text($rootScenarioPath||$i))/json
    where $json//matches
    where matches($itemPath/text(), $json//matches)
    return
      $json
 
  let $logRecord :=
    <node>
        <пользователь>{$user}</пользователь>
        <доменДанных>{$domain}</доменДанных>
        <файл>{$itemPath}</файл>
        <файл2>{config:filePath($itemPath/text())}</файл2>
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
           if(starts-with($itemPath/text(), '/'))
           then(config:filePath($itemPath/text()))
           else($itemPath/text())
           
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
  domain и пользователем из запроса или конфига 
  актуальный метод принудительного вызова обработки сценария
:)
declare 
  %rest:GET
  %rest:path("/trci-to-rdf/api/v01/sets/{$set}")
function view:main2($set){
  let $result := 
    if(file:exists(config:scenarioPath() || 'set-' || $set || '.json'))
    then(
      <result>{
        set:main(config:scenarioPath() || 'set-' || $set || '.json')
      }</result>
    )
    else(
      if(file:exists(config:scenarioPath() || $set || '.json'))
      then(
        let $setPath := config:scenarioPath() || $set || '.json'
        let $set as element(json) := json:parse(fetch:text($setPath))/json
        return
          <result>{set:sets($set, ())}</result>
      )
      else(<err:SET01>сценарий {$set} не найден</err:SET01>)
    )
  return
    $result
};