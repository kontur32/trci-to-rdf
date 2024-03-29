module namespace cccr = 'rdf/generetor/cccr/2.3';
  
import module namespace description = 'rdf/generetor/description/2.3' 
  at 'description.xqm';

declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";

(:~ CCCR основная функция :)
declare
  %public
function cccr:cccr(
  $contextRoot as element(context),
  $schemaRoot as element()
) as element(rdf:RDF)
{
  element{"rdf:RDF"}{
    description:descriptions($contextRoot, $schemaRoot/descriptions)
  }
};

