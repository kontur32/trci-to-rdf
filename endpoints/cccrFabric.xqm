module namespace view = "trci-to-rdf/view";

import module namespace set = 'trci-to-rdf/lib/evalute.set'
  at "../lib/evalute.set.xqm";

import module namespace config = 'trci-to-rdf/lib/config'
  at "../lib/config.xqm";
  
declare 
  %rest:GET
  %rest:query-param("object_name", "{$object_name}", "")
  %rest:query-param("url", "{$url}", "")
  %output:method("json")
  %rest:path("/api/v0.1/yandex/serverless/docs")
function view:main($object_name as xs:string, $url as xs:string){
  let $scenarioRootPath := 
    '/srv/nextcloud/data/lipers24.ru/files/lipers24.ru/сценарии/' 
   return
      <json type="object">
        <object__name type="string">{web:decode-url($object_name)}</object__name>
        <scenario type="string">{string-join(file:list($scenarioRootPath))}</scenario>
        <url type="string">{$url}</url>
      </json>
};