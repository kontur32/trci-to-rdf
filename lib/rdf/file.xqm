module namespace rdfFile = 'rdf/generetor/file';

import module namespace rdfGen = 'rdf/generetor' 
  at 'main.xqm';

import module namespace rdfGenTools = 'rdf/generetor/tools'
  at 'tools.xqm';

import module namespace genSchema = 'rdf/generetor/schema'
  at 'schema.xqm';

import module namespace rdfGenContext = 'rdf/generetor/lib/context'
  at 'context.xqm';

import module namespace trci = "http://www.iro37.ru/stasova/api/v1.1/parseXLSX" 
  at "../xlsx/parseXLSX-to-TRCI.xqm";

(:~ 
    преобразует trci в RDF-граф на основе автоматически сгенерированной схемы
:)
declare function rdfFile:auto-trci-to-rdf(
  $file as element(file)
) as element(Q{http://www.w3.org/1999/02/22-rdf-syntax-ns#}RDF)
{
  let $params :=
    map{
      "домен.онтология": "http://example.com/semantic/онтология/",
      "домен.схема": "http://example.com/semantic/schema/",
      "домен.сущности": "http://example.com/semantic/сущности/",
      "домен.схема.префикс": "example",
      "xmlns.rdf": "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
      "class.table": "Таблица",
      "class.row": "Строка"
    }
  return
    rdfFile:auto-trci-to-rdf($file, $params)
};

(:~ 
    преобразует trci в RDF-граф на основе автоматически сгенерированной схемы
:)
declare function rdfFile:auto-trci-to-rdf(
  $file as element(file),
  $params as map(*)
) as element(Q{http://www.w3.org/1999/02/22-rdf-syntax-ns#}RDF)
{
  let $result := 
    for $table in $file/table
    let $schema := rdfGenTools:schema(genSchema:Sample($table), $params) 
    let $localContext := rdfGenContext:context(<data>{$file}</data>, $schema)
    let $body := rdfGen:tables($localContext, $schema/table)
    return
      $body
  return
   element{QName('http://www.w3.org/1999/02/22-rdf-syntax-ns#','RDF')}{$result}
};


(:~ 
    преобразует trci в RDF-граф на основе схемы
:)
declare
  %public
function rdfFile:trci-to-rdf(
  $trci as element(file),
  $rootSchema as element(schema),
  $rootSettings as map(*)
) as element(Q{http://www.w3.org/1999/02/22-rdf-syntax-ns#}RDF)
{
 let $tables :=
    for $i in $rootSchema/tables/_
    let $fetchLocalSettings :=
      rdfGenTools:fetch($i/settings/URL/text())
    let $localSettings :=
      rdfGenTools:json-to-map(json:parse($fetchLocalSettings)/json)
    let $fetchTableSchema :=
      rdfGenTools:fetch($i/schema/URL/text())
    let $tableSchema :=
      rdfGenTools:schema($fetchTableSchema, ($localSettings, $rootSettings))
    let $contex := 
        rdfGenContext:context(<data>{$trci}</data>, $tableSchema)
    return
      rdfGen:tables($contex, $tableSchema/table)  
  return
     element{QName('http://www.w3.org/1999/02/22-rdf-syntax-ns#','RDF')}{$tables}
};

(:~ 
    преобразует xlsx в RDF-граф на основе схемы
:)
declare
  %public
function rdfFile:xlsx-to-rdf(
  $rawFile as xs:base64Binary, 
  $schema as xs:string,
  $settings as xs:string
) as element(Q{http://www.w3.org/1999/02/22-rdf-syntax-ns#}RDF)
{
  let $rootSettings :=
    rdfGenTools:json-to-map(json:parse($settings)/json)
  let $schemaFile :=
    rdfGenTools:schema($schema, $rootSettings)
  let $listOftablesWithColumnDirection := 
    string-join($schemaFile/tables/_[direction="column"]/label/text(), ";")
  let $trci :=
    trci:xlsx($rawFile, $listOftablesWithColumnDirection)
  return
    rdfFile:trci-to-rdf($trci, $schemaFile, $rootSettings)
};