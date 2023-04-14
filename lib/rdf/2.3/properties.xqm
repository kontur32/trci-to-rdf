module namespace prop = 'rdf/generetor/properties';

import module namespace rdfGenLib = 'rdf/generetor/lib'
  at 'lib.xqm';
  
import module namespace description = 'rdf/generetor/description' 
  at 'description.xqm';

declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";

(:~ генериует свойство :)
declare
  %public
function prop:property(
  $contextRoot as element(context),
  $schemaRoot 
) as element()
{
  let $QName :=
    QName(
      $schemaRoot/QName/NameSpace/text(),
      $schemaRoot/QName/PrefixedName/text()
    )
  let $types := ("URI", "literal", "descriptions")
  let $property := $schemaRoot/child::*[name()=$types]
  let $value :=
    switch($property/name())
       case "URI"
         return
           attribute{"rdf:resource"}{
             rdfGenLib:propertyValue($contextRoot, $property)
           }
       case "literal"
         return
           if($property/child::*)
           then(
             rdfGenLib:propertyValue($contextRoot, $property)
           )
           else()
       case "descriptions"
           return
             description:descriptions($contextRoot, $property)
       default 
         return
           rdfGenLib:propertyValue($contextRoot, $property)
  return
    element{$QName}{$value}
};


(:~ генериует свойства :)
declare
  %public
function prop:properties(
  $contextRoot as element(context),
  $schemaRoot 
) as element()*
{
  let $contextLocal as element(context):= 
    rdfGenLib:context($contextRoot, $schemaRoot)
  
  for $i in $contextLocal/_0040list/child::*
  
  let $contextElement as element(context) :=
    if($contextLocal/child::*/name()=$i/name())
    then(
      $contextLocal update replace node ./child::*[name()=$i/name()] with $i
    )
    else(
      $contextLocal update insert node $i into .
    )
  return
    prop:property($contextElement, $schemaRoot)
};