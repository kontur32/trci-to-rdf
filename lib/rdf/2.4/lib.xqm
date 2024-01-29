module namespace rdfGenLib = 'rdf/generetor/lib/2.4';

import module namespace rdfGenTools = 'rdf/generetor/tools/2.4'
  at 'tools.xqm';
  
import module namespace rdfSparql = 'rdf/generetor/sparql/2.4'
  at 'sparql.xqm';
  
import module namespace config = 'trci-to-rdf/lib/config'
  at "../../../lib/config.xqm";
  
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";


(:~
: Генерирует контекст
:)
declare
  %public
function rdfGenLib:context(
  $contextRoot as element(context),
  $schemaRoot as element()
) as element(context)
{
  let $localContextParams := rdfGenLib:contextParams($contextRoot, $schemaRoot)
  return
    rdfGenLib:context-update(
      $localContextParams,
      $contextRoot
    )
};

(:~
: Генерирует контекст
:)
declare
  %public
function rdfGenLib:context-update(
  $localContextParams as element()*,
  $contextRoot as element(context)
) as element(context)
{
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
  $schemaRoot as element()
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
      function($c, $xquery){
        let $modulePath := config:param('modulePath')
        let $currentExquery := 
          if(file:exists($modulePath))
          then(
              replace(
                "import module namespace modules = 'cccr/modules' at '%1';",
                "%1", $modulePath
              ) || $xquery
          )
          else($xquery)
        
        return
          xquery:eval($currentExquery, map{'':$c})
      }
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
            let $xquery := 
              if($value/xquery/text())
              then($value/xquery)
              else(
                <xquery>{fetch:text($value/xquery/URI/text())}</xquery>
              )
            return
              rdfGenLib:xquery($context, $xquery) 
        
        case 'sparql'
          return
            let $sparql := rdfGenTools:getValue($value/sparql/include)
            
            let $localContext :=
              rdfGenLib:context(
                $context,
                <_>{$value/sparql/context}</_>
              )
            
            let $endpoint as xs:anyURI :=
              if($localContext/RDF-endpoint/xs:anyURI(text()))
              then($localContext/RDF-endpoint/xs:anyURI(text()))
              else(xs:anyURI(config:param('rdfHost') || config:dataDomain() || '/sparql'))
            
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