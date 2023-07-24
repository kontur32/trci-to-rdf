module namespace rdfSparql = 'rdf/generetor/sparql/2.4';

import module namespace rdfGenTools = 'rdf/generetor/tools/2.4'
  at 'tools.xqm';
  
declare namespace  sparql-results = "http://www.w3.org/2005/sparql-results#";
  
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
) as element(sparql)
{ 
  let $contextParams := 
    map:merge(
      $context/child::*[text()]
      /map:entry(./name(), ./text())
    )
  let $query := rdfGenTools:replace($queryString, $contextParams)
  let $request as element(json):= 
    json:parse(
      fetch:text(
        web:create-url(
          $endpoint,
          map{
            "query": $query
          }
        )
      )
    )/json
  return
    <sparql>{$request/results/child::*}</sparql>
};