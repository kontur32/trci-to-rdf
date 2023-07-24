module namespace prop = 'rdf/generetor/properties/2.4';

import module namespace rdfGenLib = 'rdf/generetor/lib/2.4'
  at 'lib.xqm';
  
import module namespace description = 'rdf/generetor/description/2.4' 
  at 'description.xqm';

declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";

(:~ генериует свойство :)
declare
  %public
function prop:property(
  $contextRoot as element(context),
  $schemaRoot as element(_)
) as element()*
{
  let $QName :=
    QName(
      $schemaRoot/QName/NameSpace/text(),
      $schemaRoot/QName/PrefixedName/text()
    )
  let $types := ("URI", "literal", "description")
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
           else($property/text())
       case "description"
           return
             description:description($contextRoot, $property)
       default 
         return
           rdfGenLib:propertyValue($contextRoot, $property)
  where $value
  return
    element{$QName}{$value}
};


(:~ генериует свойства :)
declare
  %public
function prop:properties(
  $contextRoot as element(context),
  $schemaRoot as element(properties)
) as element()*
{
  for $p in $schemaRoot/_
  let $contextLocal as element(context):= rdfGenLib:context($contextRoot, $p)
  let $propertyValue :=
    if($p/context/predicates and $contextLocal/predicates/child::*)
    then(
       for $i in $contextLocal/predicates/child::*
       let $currentContext := 
         rdfGenLib:context-update(<predicate>{$i}</predicate>, $contextLocal)
       return
           prop:property($currentContext, $p)
    )
    else(
      prop:property($contextLocal, $p)
    )
  return
    $propertyValue
};