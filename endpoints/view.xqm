module namespace view = "trci-to-rdf/view";

import module namespace set = 'trci-to-rdf/lib/set' at "../lib/set.xqm";

declare 
  %rest:GET
  %rest:path("/trci-to-rdf/v")
function view:main(){
  <result>{
    set:main(
       file:base-dir() || "../example/params-files/set-root.json"
     )
  }</result>
  
};