module namespace view = "trci-to-rdf/view";

import module namespace set = 'trci-to-rdf/lib/evalute.set'
  at "../lib/evalute.set.xqm";

import module namespace config = 'trci-to-rdf/lib/config'
  at "../lib/config.xqm";

declare 
  %rest:GET
  %rest:query-param('path', '{$path}')
  %rest:path("/trci-to-rdf/v")
function view:main($path){
  <result>{
    set:main(
       $path
     )
  }</result>
};