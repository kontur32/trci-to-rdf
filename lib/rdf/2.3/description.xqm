module namespace description = 'rdf/generetor/description/2.3';

import module namespace rdfGenLib = 'rdf/generetor/lib/2.3'
  at 'lib.xqm';

import module namespace prop = 'rdf/generetor/properties/2.3' 
  at 'properties.xqm';

declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";

(:~ обрабатывает инструкцию descriptions :)
declare
  %public
function description:descriptions(
  $contextRoot as element(context),
  $schemaRoot as element(descriptions)
) 
{
  for $schemaElement in $schemaRoot/_
  return
      description:description($contextRoot, $schemaElement)
};


(:~ генерирует элемент Description :)
declare
  %public
function description:description(
  $contextRoot as element(context),
  $schemaRoot as element(_)
) as element(rdf:Description)*
{
  let $contextLocal as element(context):= 
    rdfGenLib:context($contextRoot, $schemaRoot)
  
  for $i in $contextLocal/_0040list/child::* 
  let $contextElement as element(context) :=
      <context>{
        $contextLocal/child::*[name()!=$i/name()],
        $i
      }</context>
  
  return
      element{"rdf:Description"}{
        if($schemaRoot/about)
        then(
            description:about($contextElement, $schemaRoot)
        )
        else(),
        for $i in $schemaRoot/properties/_
        return
            prop:properties($contextElement, $i)
      }
};

(:~ генерирует элемент rdf:about :)
declare
  %public
function description:about(
  $contextRoot as element(context),
  $schemaRoot as element(_)
) as attribute(rdf:about)*
{
  attribute{'rdf:about'}{
    rdfGenLib:propertyValue($contextRoot, $schemaRoot/about)
  }
};