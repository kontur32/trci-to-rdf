module namespace set = 'trci-to-rdf/lib/evalute.set';


import module namespace trci = "http://www.iro37.ru/stasova/api/v1.1/parseXLSX" 
  at "xlsx/parseXLSX-to-TRCI.xqm";

import module namespace rdfGenTools = 'rdf/generetor/tools/2.3'
  at 'rdf/2.3/tools.xqm';

import module namespace cccr.2.3 = 'rdf/generetor/cccr/2.3'
  at 'rdf/2.3/cccr.xqm';
  
import module namespace cccr.2.4 = 'rdf/generetor/cccr/2.4'
  at 'rdf/2.4/cccr.xqm';

import module namespace fuseki2 = 'http://garpix.com/semantik/app/fuseki2'
  at 'fuseki2.client.xqm';
  
import module namespace config = 'trci-to-rdf/lib/config'
  at "../lib/config.xqm";

declare function set:output(
  $output as element(output),
  $rdf as element(),
  $parameters as element(parameters)?
){
   if($output/_)
    then(
      for $i in $output/_
      return
        switch ($i/type/text())
        case 'file'
          return
            file:write($i/path/text(), $rdf)
        case 'console'
          return
              $rdf
        case 'remote'
          return
          let $graphName := $i/parameters/graphName/text()
          let $server :=
            if($i/server/endpoint)
            then($i/server//endpoint/text())
            else(
              if($parameters/remote/sparql/endpoint/text())
              then($parameters/remote/sparql/endpoint/text())
              else('http://fuseki:3030/' || config:dataDomain())
            )
          let $result :=
            fuseki2:upload-rdf(
              $rdf,
              xs:anyURI($graphName),
              xs:anyURI($server)
            )
          return
            (
              "Загрузка графа <" || $graphName || ">: ",
               $result
            ) 
        default return ()
    )
    else()
};

declare
  %private
function set:sets(
  $set as element(json),
  $parameters as element(parameters)*
){
   
  let $output as element(output) := $set/output
  let $columnDirectionList := $set/source/_/directory/column/text()
  let $fileURIs as xs:anyURI* :=
    if($set/source/_)
    then(
      let $path := $set/source/_/directory/path/text()
      let $dirPath := set:setPath($path)
      let $files := file:list($dirPath)
      for $i in $files
      where matches($i, $set/source/_/directory/mask/text())
      return
        xs:anyURI(
          $dirPath || $i
        )
    )
    else(
      xs:anyURI(
        set:setPath($set/source/text())
      )
    )
  let $result :=
    for $fileURI in $fileURIs
    let $rawData as xs:base64Binary := fetch:binary($fileURI)
    let $trci as element(file) := 
      trci:xlsx($rawData, $columnDirectionList)
      update insert node attribute {'URI'}{$fileURI} into .
    
    let $contextRoot as element(context) := <context>{$trci}</context>
    
    let $schemaPath as xs:anyURI := $set/schema/xs:anyURI(set:setPath(text()))
    let $schemaRoot as element(json) := rdfGenTools:schemaFetch($schemaPath)
    
    return
      switch ($schemaRoot/version/text())
      case '2.3'
        return cccr.2.3:cccr($contextRoot, $schemaRoot)
      case '2.4'
        return cccr.2.4:cccr($contextRoot, $schemaRoot)
      default 
        return cccr.2.3:cccr($contextRoot, $schemaRoot)
  
  return
    set:output(
      $output,
      $result,
      $parameters
    )
};

(:
  генерирует полный путь
:)
declare function set:setPath($path as xs:string) as xs:string {
  starts-with($path, '/') ?? $path !! config:rootPath() || $path
};

(:
  обрабатывает сценарии из набора
:)
declare function set:main($path as xs:string){
  let $sets := json:parse(fetch:text($path))/json
  for $path in $sets/set/_
  let $setPath := set:setPath($path)
  let $set as element(json) := json:parse(fetch:text($setPath))/json
  let $parameters as element(parameters)* := $sets/parameters
  return
    set:sets($set, $parameters)
};