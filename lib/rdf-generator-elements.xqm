module namespace rdfGenElements = 'rdf/generetor/elements';

import module namespace rdfGenLib = 'rdf/generetor/lib'
  at 'rdf-generator-lib.xqm';
  
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";

(:~
 : Генерирует элемент rdf:resource
 : @param $uri 
 : @return аттрибут rdf:resource
:)
declare
  %public
function rdfGenElements:attributeResource(
  $uri as xs:anyURI
) as attribute(rdf:resource)
{
  attribute{"rdf:resource"}{$uri}
};


(:~
 : Генерирует элемент rdf:about
 : @param $about контекст данных (данные и общие параметры схемы)
 : @param $elements элементы для добавления в контектс
 : @return возвращает контекст 
:)
declare
  %public
function rdfGenElements:buidElementAbout(
  $context as element(data),
  $schema as element()*
) as attribute(rdf:about)*
{
  if($schema)
  then(
    attribute{'rdf:about'}{
      rdfGenLib:propertyValue($context, $schema, $context/aliases)
    }
  )
  else()
};

(:~
 : Генерирует элемент rdf:about
 : @param $about контекст данных (данные и общие параметры схемы)
 : @param $elements элементы для добавления в контектс
 : @return возвращает контекст 
:)
declare
  %public
function rdfGenElements:description(
  $context as element(data),
  $schema as element()*,
  $body as element()*
) as element(rdf:Description)
{
  let $about :=
    rdfGenElements:buidElementAbout($context, $schema/about)
  return
    element{'rdf:Description'}{if($about)then($about)else(), $body}
};

(:~
 : Генерирует элемент rdf:RDF
 : @param $body тело элемента
:)
declare
  %public
function rdfGenElements:RDF(
  $body as element()*
) as element(rdf:RDF)
{
  <rdf:RDF>{$body}</rdf:RDF>
};