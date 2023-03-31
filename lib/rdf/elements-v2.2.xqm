module namespace rdfGenElements = 'rdf/generetor/elements';

import module namespace rdfGenLib = 'rdf/generetor/lib' at 'lib-v2.2.xqm';
  
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";

(:~
 : Генерирует элемент rdf:about
 : @param $about контекст данных (данные и общие параметры схемы)
 : @param $elements элементы для добавления в контектс
 : @return возвращает контекст 
:)
declare
  %public
function rdfGenElements:elementRecource(
  $resource as xs:string*
) as attribute(rdf:resource)*
{
  if($resource)
  then(
    attribute{'rdf:resource'}{$resource}
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
function rdfGenElements:buidElementAbout(
  $context as element(),
  $schema as element()*
) as attribute(rdf:about)*
{
  if($schema)
  then(
    attribute{'rdf:about'}{
      rdfGenLib:propertyValue($context, $schema)
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
  $context as element(context),
  $schema as element(container)
) as element(rdf:Description)
{
  let $about := rdfGenElements:buidElementAbout($context, $schema/about)
  return
    element{'rdf:Description'}{$about}
};

(:~
 : Генерирует элемент rdf:RDF
 : @param $about контекст данных (данные и общие параметры схемы)
 : @param $elements элементы для добавления в контектс
 : @return возвращает контекст 
:)
declare
  %public
function rdfGenElements:RDF(
  $body as element()*
) as element(rdf:RDF)
{
    element{'rdf:RDF'}{$body}
};