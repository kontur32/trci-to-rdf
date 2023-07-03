import module namespace rdfSparql = "rdf/generetor/sparql"
  at "/opt/basex/webapp/garpix/trci-to-rdf/lib/rdf/2.3/sparql.xqm";

declare function local:заполнитьФорму($данныеДляФормы, $шаблон, $endpoint){
 let $request :=
    <http:request method='post'>
      <http:multipart media-type = "multipart/form-data" >
        <http:header name="Content-Disposition" value= 'form-data; name="template";'/>
        <http:body media-type = "application/octet-stream">{$шаблон}</http:body>
        <http:header name="Content-Disposition" value= 'form-data; name="data";'/>
        <http:body media-type = "application/xml">{$данныеДляФормы}</http:body>
      </http:multipart> 
    </http:request> 
  let $response := 
    http:send-request ($request, $endpoint)
  return 
      $response[2]
};

declare function local:обеспечениеКвалификации($data) as element(table){
  <table>
      {
        for $i in $data
        return
          <row>
            <cell>{$i/наименованиеРаботы/value/text()}</cell>
            <cell>{$i/результатРаботы/value/text()}</cell>
            <cell>{$i/объем/value/text()}</cell>
          </row>
      }
      <row>
        <cell>Всего</cell>
        <cell></cell>
        <cell>{sum($data/объем/value/number())}</cell>
      </row>
    </table>
};
declare function local:проектнаяРабота($data) as element(table){
  <table>
      {
        for $i in $data
        return
          <row>
            <cell>{$i/видРаботы/value/text()}</cell>
            <cell>{$i/наименованиеРаботы/value/text()}. {$i/результатРаботы/value/text()}</cell>
            <cell>{$i/объем/value/text()}</cell>
          </row>
      }
      <row>
        <cell>Всего</cell>
        <cell></cell>
        <cell>{sum($data/объем/value/number())}</cell>
      </row>
    </table>
};
declare function local:организационнаяРабота($data) as element(table){
  <table>
      {
        for $i in $data
        return
          <row>
            <cell>{$i/видРаботы/value/text()}</cell>
            <cell>{$i/результатРаботы/value/text()}</cell>
            <cell>{$i/объем/value/text()}</cell>
          </row>
      }
      <row>
        <cell>Всего</cell>
        <cell></cell>
        <cell>{sum($data/объем/value/number())}</cell>
      </row>
    </table>
};
declare function local:методическаяРабота($data) as element(table){
  <table>
      {
        for $i in $data
        return
          <row>
            <cell>{$i/видРаботы/value/text()}</cell>
            <cell>{$i/наименованиеРаботы/value/text()}</cell>
            <cell>{$i/результатРаботы/value/text()}</cell>
            <cell>{$i/объем/value/text()}</cell>
          </row>
      }
      <row>
        <cell>Всего</cell>
        <cell></cell>
        <cell></cell>
        <cell>{sum($data/объем/value/number())}</cell>
      </row>
    </table>
};

declare function local:научнаяРабота($data) as element(table){
  <table>
      {
        for $i in $data
        return
          <row>
            <cell>{$i/тематикаНаучнойРаботы/value/text()}</cell>
            <cell>{$i/видУчебнойРаботы/value/text()}</cell>
            <cell>{$i/результатНаучнойРаботы/value/text()}</cell>
            <cell>{$i/объем/value/text()}</cell>
          </row>
      }
      <row>
        <cell>Всего</cell>
        <cell></cell>
        <cell></cell>
        <cell>{sum($data/объем/value/number())}</cell>
      </row>
    </table>
};


declare function local:учебнаяРабота($data) as element(table) {
    <table>
      {
        for $i in $data
        return
          <row>
            <cell>{$i/дисциплина/value/text()}</cell>
            <cell>{$i/видРаботы/value/text()}</cell>
            <cell>{$i/семестр/value/text()}</cell>
            <cell>{$i/группа/value/text()}</cell>
            <cell>{$i/числоОбучающихся/value/text()}</cell>
            <cell>{$i/объем/value/text()}</cell>
          </row>
      }
      <row>
        <cell>Всего</cell>
        <cell></cell>
        <cell></cell>
        <cell></cell>
        <cell></cell>
        <cell>{sum($data/объем/value/number())}</cell>
      </row>
    </table>
};

declare function local:данныеПреподавателя($context) as element(context) {
  let $запрос := 
    fetch:text(
      "C:\Users\kontu\Nextcloud2\мисис\запросы\сведения-о-преподавателе.rq"
    )
  let $data :=
      rdfSparql:request(
        $запрос,
        $context,
       xs:anyURI("http://81.177.136.214:3030/kik-misis/sparql")
     )/bindings/_
     
  return
    $context update insert node
    for-each($data/child::*, function($v){element{$v/name()}{$v/value/text()}})
    into .
};

let $аудиторные := ('Лекционные', 'Лабораторные', 'Практические')

let $запрос := 
  fetch:text(
    "C:\Users\kontu\Nextcloud2\мисис\запросы\учебная-нагрузка-по-преподавателю.rq"
  )
let $context := 
  <context>
    <фамилия>Бакулев</фамилия>
    <имя>Константин</имя>
    <отчество>Станиславович</отчество>
  </context>

let $data :=
    rdfSparql:request(
      $запрос,
      $context,
     xs:anyURI("http://81.177.136.214:3030/kik-misis/sparql")
   )/bindings/_
   
let $учебнаяРабота := $data[раздел/value/text()="учебнаяРабота"]
let $научнаяРабота := $data[раздел/value/text()="научнаяРабота"]
let $вспомогательнаяРабота := 
  $data[not(раздел/value/text()=("учебнаяРабота","научнаяРабота"))]
let $методическаяРабота := $data[раздел/value/text()="методическаяРабота"]
let $организационнаяРабота := $data[раздел/value/text()="организационнаяРабота"]
let $проектнаяРабота := $data[раздел/value/text()="проектнаяРабота"]
let $обеспечениеКвалификации := $data[раздел/value/text()="обеспечениеКвалификации"]

let $trci :=
  <table>
      <row id="fields">
        {
          for $i in local:данныеПреподавателя($context)/child::*
          return
            <cell id="{$i/name()}">{$i/text()}</cell>
        }
        <cell id="урГод">{sum($учебнаяРабота/объем/value/number())}</cell>
        <cell id="урОсень">{sum($учебнаяРабота[(семестр/value/number() div 2)!=(семестр/value/number() idiv 2)]/объем/value/number())}</cell>
        <cell id="урВесна">{sum($учебнаяРабота[(семестр/value/number() div 2)=(семестр/value/number() idiv 2)]/объем/value/number())}</cell>
        <cell id="нрГод">{sum($научнаяРабота/объем/value/number())}</cell>
        <cell id="всрГод">{sum($вспомогательнаяРабота/объем/value/number())}</cell>
        <cell id="мрГод">{sum($методическаяРабота/объем/value/number())}</cell>
        <cell id="орГод">{sum($организационнаяРабота/объем/value/number())}</cell>
        <cell id="прГод">{sum($проектнаяРабота/объем/value/number())}</cell>
        <cell id="квГод">{sum($обеспечениеКвалификации/объем/value/number())}</cell>
        <cell id="всегоГод">{sum($data/объем/value/number())}</cell>
      </row>
      <row id="tables">
        <cell id="аудиторнаяУчебнаяРабота">{
          local:учебнаяРабота(
            $учебнаяРабота
            [видРаботы/value/text() = $аудиторные]
          )
        }</cell>
        <cell id="инаяУчебнаяРабота">{
          local:учебнаяРабота(
            $учебнаяРабота
            [not(видРаботы/value/text() = $аудиторные)]
          )
        }</cell>
        <cell id="научнаяРабота">{
          local:научнаяРабота($научнаяРабота)
        }</cell>
        <cell id="методическаяРабота">{
          local:методическаяРабота($методическаяРабота)
        }</cell>
        <cell id="организационнаяРабота">{
          local:организационнаяРабота($организационнаяРабота)
        }</cell>
        <cell id="проектнаяРабота">{
          local:проектнаяРабота($проектнаяРабота)
        }</cell>
        <cell id="обеспечениеКвалификации">{
          local:обеспечениеКвалификации($обеспечениеКвалификации)
        }</cell>
      </row>
  </table>

return
 (
   $trci,
    file:write-binary(
    "C:\Users\kontu\Desktop\индплан.docx",
    local:заполнитьФорму(
     $trci,
     file:read-binary("C:\Users\kontu\Nextcloud2\мисис\шаблоны\индивидуальный-план.docx"),
     "http://localhost:8984/api/v1/ooxml/docx/template/complete"
   )
  )
)
  