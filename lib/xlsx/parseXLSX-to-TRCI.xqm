module namespace parse = "http://www.iro37.ru/stasova/api/v1.1/parseXLSX";

import module  namespace xlsx = 'http://iro37.ru.ru/xq/modules/xlsx' 
  at 'parseXLSX.xqm';

(: парсит все листы кники xlsx в формат trci :)
declare 
  %public
function 
  parse:xlsx(
    $rawFile as xs:base64Binary) as element(file)
{
   parse:xlsx($rawFile, "")
};


(: парсит все листы кники xlsx в формат trci :)
declare 
  %public
function 
  parse:xlsx(
    $rawFile as xs:base64Binary,
    $columnDirection as xs:string) as element(file)
{
  let $sheetsList :=
    archive:entries($rawFile)[contains(./text(), 'xl/worksheets/sheet')]/text()
  let $rels1 := parse-xml(archive:extract-text($rawFile, 'xl/_rels/workbook.xml.rels'))
  let $rels2 := parse-xml(archive:extract-text($rawFile, 'xl/workbook.xml'))
  let $sheets := parse:sheetPath($rawFile)
  let $sheetWithСolumnDirection := tokenize($columnDirection, ';')
  let $sheetsTRCI :=
    for $sheetPath in $sheets
    let $target := substring-after($sheetPath?sheetPath, 'xl/')
    let $IsColumnDirection := 
      if($sheetPath?targetSheetName=$sheetWithСolumnDirection)
      then(true())
      else(false())
    order by $target
    return
     xlsx:binary-to-TRCI($rawFile, $sheetPath?sheetPath, $IsColumnDirection)
     update insert node attribute {'label'} {$sheetPath?targetSheetName} into .
  return
    <file>{$sheetsTRCI}</file>
};

declare
  %private
function parse:sheetPath($file as xs:base64Binary) as map(*)*
{
  let $sheetsList := 
    archive:entries($file)[contains( ./text(), 'xl/worksheets/sheet')]/text() 
  let $rels1 := parse-xml(archive:extract-text($file, 'xl/_rels/workbook.xml.rels'))
  let $rels2 := parse-xml(archive:extract-text($file, 'xl/workbook.xml'))
  for $sheetPath in $sheetsList
  let $target := substring-after($sheetPath, 'xl/')
  let $sheetID :=
    $rels1/*:Relationships/*:Relationship[@*:Target = $target]/@*:Id/data()
  let $sheetName :=
    $rels2//*:sheet[@*:id/data() = $sheetID]/@*:name/data()
  return
      map{
        "targetSheetName":$sheetName,
        "sheetPath":$sheetPath
      }
};
