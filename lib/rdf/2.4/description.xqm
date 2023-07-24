module namespace description = 'rdf/generetor/description/2.4';
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";

import module namespace rdfGenLib = 'rdf/generetor/lib/2.4' at 'lib.xqm';
import module namespace prop = 'rdf/generetor/properties/2.4' at 'properties.xqm';

(:~ генерирует элемент Description :)
declare
  %public
function description:description(
  $contextRoot as element(context),
  $schemaRoot as element(description)
) as element(rdf:Description)
{
  let $contextLocal as element(context):= 
    rdfGenLib:context($contextRoot, $schemaRoot)
  return
      element{"rdf:Description"}{
        description:about($contextLocal, $schemaRoot),
        prop:properties($contextLocal, $schemaRoot/properties)
      }
};

(:~ генерирует элемент rdf:about :)
declare
  %public
function description:about(
  $contextRoot as element(context),
  $schemaRoot as element()
) as attribute(rdf:about)*
{
  if($schemaRoot/about)
  then(
    attribute{'rdf:about'}{
      rdfGenLib:propertyValue($contextRoot, $schemaRoot/about)
    }
  )
  else()
};