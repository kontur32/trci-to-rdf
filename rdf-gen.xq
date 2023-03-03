import module namespace rdfGen = 'rdf/generetor'
  at 'rdf-generator.xqm';
import module namespace rdfGenTools = 'rdf/generetor/tools'
  at 'rdf-generator-tools.xqm';
import module namespace genSchema = 'rdf/generetor/schema'
  at 'rdf-generator-schema.xqm';


let $path := 
  'http://a.roz37.ru/lipers/семантический.контракт/мисис/анкета-преподавателя/анкетные-данные/'
let $context := <data>{fetch:xml(iri-to-uri($path||"example-input.xml"))/file}</data>
let $params :=
  rdfGenTools:json-to-map(fetch:text(iri-to-uri($path||'params.json'))) 

return
  rdfGen:trci-to-rdf($context, $params)