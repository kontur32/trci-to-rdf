module namespace view = "trci-to-rdf/view";

import module namespace cccFabric = 'trci-to-rdf/lib/evalute.cccFabric'
  at "../lib/cccrFabric.xqm";
  
import module namespace set = 'trci-to-rdf/lib/evalute.set'
  at "../lib/evalute.set.xqm";
  
import module namespace config = 'trci-to-rdf/lib/config'
  at "../lib/config.xqm";
  
declare 
  %rest:GET
  %rest:query-param("domain", "{$domain}", "")
  %rest:query-param("bucket_name", "{$bucket_name}", "")
  %rest:query-param("object_name", "{$object_name}", "")
  %rest:query-param("file_url", "{$file_url}", "")
  %rest:query-param("schema_url", "{$schema_url}", "")
  %rest:query-param("scenario_url", "{$scenario_url}", "")
  %output:method("json")
  %rest:path("/api/v0.1/yandex/serverless/docs")
function view:main($domain, $bucket_name as xs:string, $object_name as xs:string, $file_url as xs:string, $schema_url, $scenario_url){
  let $object := web:decode-url($object_name)  
  let $scenario := try{json:parse(fetch:text($scenario_url))/json}catch*{}
  let $rdf := 
    if($scenario)
    then(
      try{
        cccFabric:cccrFabric(xs:anyURI($schema_url), xs:anyURI($file_url))
      }catch*{}
    )
    else()
  
  let $output := 
    if($rdf)
    then(
      try{
        let $context :=  <context><file URI="{$domain || '/' || $object}"/></context>
        return
          set:output($scenario/output, $rdf, (), $context)
           => serialize()
      }catch*{"не удалось выполнить сценарий"}
    )
    else("не удалось сгенерировать rdf")
    
  return
      <json type="object">
        <bucket__name type="string">{$bucket_name}</bucket__name>
        <object__name type="string">{$object}</object__name>
        <scenario type="object">
          <output type="string">{serialize($scenario/output)}</output>
          <schema type="object">
            <path type="string">{$schema_url}</path>
            <exists type="string">{}</exists>
          </schema>
        </scenario>
        <file__url type="string">{$file_url}</file__url>
        <output type="string">{$output}</output>
      </json>
};