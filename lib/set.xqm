module namespace set = 'trci-to-rdf/lib/set';


import module namespace trci = "http://www.iro37.ru/stasova/api/v1.1/parseXLSX" 
  at "xlsx/parseXLSX-to-TRCI.xqm";

import module namespace rdfGenTools = 'rdf/generetor/tools'
  at 'rdf/2.3/tools.xqm';

import module namespace cccr = 'rdf/generetor/cccr'
  at 'rdf/2.3/cccr.xqm';

import module namespace fuseki2 = 'http://garpix.com/semantik/app/fuseki2'
  at 'fuseki2.client.xqm';

declare function set:set(
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
            if($i/server)
            then($i/server)
            else($parameters/remote/sparql)
          let $result :=
            fuseki2:upload-rdf(
              $rdf,
              $graphName,
              $server/endpoint/text()
            )
          return
            (
              "Загрузка графа <" || $graphName || ">: " ||
              ($result=("200", "201")??"ОК" !! 'Ошибка: ' || string-join($result, ', '))
            ) 
        default return ()
    )
    else()
};

declare function set:sets($sets as element(json)){
  for $setPath in $sets/set/_
  let $set as element(json) := json:parse(fetch:text($setPath))/json
  let $parameters as element(parameters) := $sets/parameters
  let $output as element(output) := $set/output
  
  let $rawFile as xs:base64Binary := fetch:binary($set/source/text())
  let $trci as element(file) := trci:xlsx($rawFile)
  let $contextRoot as element(context) := <context>{$trci}</context>
  
  let $schemaPath as xs:anyURI := $set/schema/xs:anyURI(text())
  let $schemaRoot as element(json) := rdfGenTools:schemaFetch($schemaPath)
  
  let $rdf as element() := cccr:cccr($contextRoot, $schemaRoot)
  return
    set:set($output, $rdf, $parameters)
};


declare function set:main($path as xs:string){
  let $sets := 
  json:parse(
    fetch:text($path)
  )/json

return
  set:sets($sets)
};