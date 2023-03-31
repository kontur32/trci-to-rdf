module namespace rdfSparql = 'rdf/generetor/sparql';

declare namespace  sparql-results = "http://www.w3.org/2005/sparql-results#";

import module namespace rdfGenTools = 'rdf/generetor/tools'
  at 'tools.xqm';
  
(:~
 : Выполняет запрос к RDF-базе
 : @param $queryString строка со SPARQL-запросом
 : @param $context 
 : @return возвращает значение 
:)
declare
  %public
function rdfSparql:request(
  $queryString as xs:string,
  $context as element(context),
  $endpoint as xs:anyURI
) as xs:string*
{
  let $contextParams := 
    map:merge(
      $context/child::*[text()]/map:entry(./name(), ./text())
    )
  let $query := rdfGenTools:replace($queryString, $contextParams)
  let $request as element(_):= 
    json:parse(
      fetch:text(
        web:create-url(
          $endpoint,
          map{
            "query": $query
          }
        )
      )
    )/json/results/bindings/_
  return
    $request/result/value/text()
};