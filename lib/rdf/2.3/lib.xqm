module namespace rdfGenLib = 'rdf/generetor/lib';

import module namespace rdfGenTools = 'rdf/generetor/tools'
  at 'tools.xqm';
  
import module namespace rdfSparql = 'rdf/generetor/sparql'
  at 'sparql.xqm';
  
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";


(:~
: Генерирует контекст
:)
declare
  %public
function rdfGenLib:context(
  $contextRoot as element(context),
  $schemaRoot as element(_)
) as element(context)
{
  let $localContextParams := 
      rdfGenLib:contextParams($contextRoot, $schemaRoot)
    
  return
    fold-left(
        $localContextParams,
        $contextRoot,
        function($c, $p){
          if($c/child::*/name()=$p/name())
          then($c update replace node ./child::*[name()=$p/name()] with $p)
          else($c update insert node $p into .)
        }
      )
};

(:~
: Генерирует параметры контекста
:)
declare
  %private
function rdfGenLib:contextParams(
  $contextRoot as element(context),
  $schemaRoot as element(_)
) as element()*
{
  for $i in $schemaRoot/context/child::*
  return
    if($i/child::*)
    then(
      element{$i/name()}
      {rdfGenLib:propertyValue($contextRoot, $i)}
    )
    else($i)
};

(:~
: Генерирует значение элемента
:)
declare
  %public
function rdfGenLib:propertyValue(
  $context as element(context),
  $schema as element()
) as item()*
{
  let $result :=
    if($schema/compute/child::*)
    then(
      let $value := $schema/compute
      let $xquery :=
        switch ($value/child::*/name())
        case 'xquery'
          return
            let $xqueries := 
              if($value/xquery/child::*)
              then($value/xquery/child::*/text())
              else($value/xquery/text())
            return
              fold-left(
                $xqueries,
                $context,
                function($c, $xquery){xquery:eval($xquery, map{'':$c})}
              )
        
        case 'sparql'
          return
            let $sparql := rdfGenTools:getValue($value/sparql)
            
            let $localContext :=
              rdfGenLib:context(
                $context,
                <_>{$value/sparql/context}</_>
              )
            
            let $endpoint as xs:anyURI :=
              $localContext/RDF-endpoint/xs:anyURI(text())
            
            return
              rdfSparql:request($sparql, $localContext, $endpoint)
        
        default
          return
            let $xq := $value/xquery/text()
            return
              xquery:eval($xq, map{'':$context})
      return
       $xquery
    )
    else($schema/text())
   return
     $result
};