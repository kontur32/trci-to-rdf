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
  let $localContextParams := rdfGenLib:contextParams($contextRoot, $schemaRoot)
    
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
      let $propertyValue := rdfGenLib:propertyValue($contextRoot, $i)
      return
        element{$i/name()}{$propertyValue}
    )
    else($i)
};

(:~
: Вычисляет значение xquery
:)
declare
  %public
function rdfGenLib:xquery(
  $context as element()*,
  $schema as element(xquery)
) as item()*
{
  let $xqueries := 
    if($schema/child::*)
    then(
     $schema/child::*/text()
    )
    else($schema/text())
  return
    fold-left(
      $xqueries,
      $context,
      function($c, $xquery){xquery:eval($xquery, map{'':$c})}
    )
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
            rdfGenLib:xquery($context, $value/xquery) 
        
        case 'sparql'
          return
            let $sparql := rdfGenTools:getValue($value/sparql/include)
            
            let $localContext :=
              rdfGenLib:context(
                $context,
                <_>{$value/sparql/context}</_>
              )
            
            let $endpoint as xs:anyURI :=
              $localContext/RDF-endpoint/xs:anyURI(text())
            let $results as element(sparql) :=
              rdfSparql:request($sparql, $localContext, $endpoint)
            return
              if($value/sparql/xquery)
              then(
                let $localContext2 :=
                  $localContext update insert node $results into .
                return
                  rdfGenLib:xquery($localContext2, $value/sparql/xquery)
              )
              else($results)
        
        default
          return
            rdfGenLib:xquery($context, $value/xquery)
      return
       $xquery
    )
    else($schema/text())
   return
     $result
};