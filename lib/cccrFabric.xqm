module namespace cccFabric = 'trci-to-rdf/lib/evalute.cccFabric';

import module namespace trci = "http://www.iro37.ru/stasova/api/v1.1/parseXLSX" 
  at "xlsx/parseXLSX-to-TRCI.xqm";
  
import module namespace cccr = 'rdf/generetor/cccr/2.4'
  at 'rdf/2.4/cccr.xqm';

(:
  обрабатывает данные (конетекст) заданным сценарием
:)
declare
  %public
function cccFabric:cccrFabric(
  $schemaURI as  xs:anyURI,
  $fileURI as xs:anyURI
) as element(Q{http://www.w3.org/1999/02/22-rdf-syntax-ns#}RDF) {
  let $schemaRoot as element(json) := 
    ($schemaURI => fetch:binary() => convert:binary-to-string()=> json:parse())/json
  let $contextRoot as element (context) := 
    element{'context'}{
      $fileURI => fetch:binary() => cccFabric:parseData($schemaRoot)
      update insert node attribute {'URI'}{$fileURI} into .
    }
  return
    cccr:cccr($contextRoot, $schemaRoot)  
};


(:
  парсит бинарные данные и упаковывает в контекст
:)
declare
  %public
function cccFabric:parseData(
  $rawData as xs:base64Binary,
  $schemaRoot as element(json)
) as element(file) {
  let $mimeType := $schemaRoot/mimeType/text()
  let $columnDirectionList := $schemaRoot/columnDirectionList/text()
  let $data := 
    switch($mimeType)
    case "xlsx"return
      trci:xlsx($rawData, $columnDirectionList)/file/child::*
    case "docx"return
      element{'file'}{
        parse-xml(archive:extract-text($rawData, 'word/document.xml'))
      }
    case "xml" return
      element{'file'}{
        ($rawData => convert:binary-to-string()=> parse-xml())/child::*
      }
    default return
      trci:xlsx($rawData, $columnDirectionList)
   return
     $data
};