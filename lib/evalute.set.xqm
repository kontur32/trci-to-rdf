module namespace set = 'trci-to-rdf/lib/evalute.set';

declare namespace rdf ="http://www.w3.org/1999/02/22-rdf-syntax-ns#";

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
  
import module namespace rdfGenLib = 'rdf/generetor/lib/2.4' at 'rdf/2.4/lib.xqm';

(: выводит результаты обработки сценария :)
declare function set:output(
  $output as element(output),
  $rdf as element(),
  $parameters as element(parameters)?,
  $context as element(context)
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
          let $graphName := rdfGenLib:propertyValue($context, $i/parameters/graphName)
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
              "Endpoint: " || $server,
              "Загрузка графа <" || $graphName || ">: ",
               $result
            ) 
        default return ()
    )
    else()
};

declare
  %public
function set:sets(
  $set as element(json),
  $parameters as element(parameters)*
){
  set:sets($set, $parameters, '')
};

declare
  %public
function set:sets(
  $set as element(json),
  $parameters as element(parameters)*,
  $sourcePath as xs:string*
){
   
  let $output as element(output) := $set/output
  let $columnDirectionList := $set/source/_/directory/column/text()
  
  let $fileURIs as xs:anyURI* :=
    if($set/source/_)
    then(
      let $path := $set/source/_/directory/path/text()
      let $dirPath := config:setPath($path)
      let $files := file:list($dirPath)
      for $i in $files
      where matches($i, $set/source/_/directory/mask/text())
      return
        xs:anyURI(
          $dirPath || $i
        )
    )
    else(
      if($set/source/text())
      then(
        xs:anyURI(
          config:setPath($set/source/text())
        )
      )
      else(
        xs:anyURI(config:setPath($sourcePath))
      )
    )
  
  let $result :=
    for $fileURI in $fileURIs
    
    let $trci as element(file) := 
      switch(replace($fileURI, ".*.([a-z]{4})$", "$1"))
      case "xlsx"return
        let $rawData as xs:base64Binary := fetch:binary($fileURI)
        return
          trci:xlsx($rawData, $columnDirectionList)
          update insert node attribute {'URI'}{$fileURI} into .
      case "docx"return
        let $rawData as xs:base64Binary := fetch:binary($fileURI)
        return
          <file>{parse-xml(archive:extract-text($rawData, 'word/document.xml'))}</file>
          update insert node attribute {'URI'}{$fileURI} into .
      default return
        <file>{fetch:xml($fileURI)/child::*}</file>
        update insert node attribute {'URI'}{$fileURI} into .
        
    let $contextRoot as element(context) := <context>{$trci}</context>
    
    let $schemaPath as xs:anyURI := $set/schema/xs:anyURI(config:setPath(text()))
    let $schemaRoot as element(json) := rdfGenTools:schemaFetch($schemaPath)
    
    let $rdf := 
      switch ($schemaRoot/version/text())
      case '2.3'
        return cccr.2.3:cccr($contextRoot, $schemaRoot)
      case '2.4'
        return cccr.2.4:cccr($contextRoot, $schemaRoot)
      default 
        return cccr.2.3:cccr($contextRoot, $schemaRoot)
  
    return
     [
        $output,
        $rdf,
        $parameters,
        $contextRoot
    ]
  return
    set:output(
      $output,
      element{"rdf:RDF"}{$result?2/rdf:Description},
      $parameters,
      $result[1]?4
    )
};

(:
  обрабатывает сценарии из набора
:)
declare
  %public
function set:main(
  $path as xs:string
){
  set:main($path, '')
};

(:
  обрабатывает сценарии из набора
:)
declare
  %public
function set:main(
  $setPath as xs:string,
  $sourcePath as xs:string*
){
  let $sets := json:parse(fetch:text($setPath))/json
  let $parameters as element(parameters)* := $sets/parameters
  for $path in $sets/set/_
  let $setPath := config:setPath($path)
  let $set as element(json) := json:parse(fetch:text($setPath))/json
  return
    set:sc($path, $parameters, $sourcePath)
};

(:
  обрабатывает один сценарий
:)
declare
  %public
function set:sc(
  $scPath as xs:string,
  $parameters as element(parameters)*,
  $sourcePath as xs:string*
){
  let $setPath := config:setPath($scPath)
  let $set as element(json) := json:parse(fetch:text($setPath))/json
  return
    set:sets($set, $parameters, $sourcePath)
};