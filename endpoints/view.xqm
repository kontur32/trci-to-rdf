module namespace view = "trci-to-rdf/view";

import module namespace set = 'trci-to-rdf/lib/evalute.set'
  at "../lib/evalute.set.xqm";

declare 
  %rest:POST('{$f}')
  %rest:form-param("file","{$file}")
  %rest:path("/trci-to-rdf/v/file")
  %public
function view:upload($file, $f){
  file:write-text(file:base-dir() || '../var/' || random:uuid()||'.txt', $f)
};

declare 
  %rest:GET
  %rest:query-param('path', '{$path}')
  %rest:query-param('root-path', '{$root-path}', '/srv/nextcloud/data/kontur32/files/')
  %rest:path("/trci-to-rdf/v")
function view:main($path, $root-path){
  <result>{
    set:main(
       $root-path || $path
     )
  }</result>
};