module namespace genSchema = 'rdf/generetor/schema';

declare function genSchema:Sample($table){
  let $поля := 
    for $i in $table/row[1]/cell
    count $c
    return
      <_ type="object">
        {
          element{'mask'}{'^'||$i/@label},
          element{'type'}{'subject'},
          element{'nameSpace'}{'{{домен.схема}}'},
          element{'localName'}{'misis:свойство-' || $c},
          element{'value'}{
             attribute{'type'}{'object'},
             element{'alias'}{'парсер-нормализация-пробелов'}
           },
          element{'validator'}{
             attribute{'type'}{'object'},
             element{'alias'}{'валидация-текста'}
           },
           <properties type="array">
              <_ type="object">
                <type>property</type>
                <nameSpace><![CDATA[{{домен.схема}}]]></nameSpace>
                <localName>misis:label</localName>
                <value type="object"><xquery>./@label/data()</xquery></value>
              </_>
              <_ type="object">
                <type>property</type>
                <nameSpace><![CDATA[{{домен.схема}}]]></nameSpace>
                <localName>misis:значение</localName>
                <value type="object"><xquery>./text()</xquery></value>
              </_>
            </properties>
        }
      </_>
  
  return
    json:serialize(
      <json type="object">
        <schema type="object">
          <context type="object">
            <aliases type="object">
              <парсер-нормализация-пробелов type="object">
                <xquery>normalize-space(.)</xquery>
              </парсер-нормализация-пробелов>
            </aliases>
            <parameters type="object">
              <домен.сущности><![CDATA[{{домен.сущности}}]]></домен.сущности>
              <домен.сущности.строки><![CDATA[{{домен.сущности}}]]>строки</домен.сущности.строки>
            </parameters>
          </context>
          <table type="object">
            <type>subject</type>
            <filter type="object">
              <value type="object">
                <xquery>matches(./table/@label, '^{$table/@label/data()}')</xquery>
              </value>
            </filter>
            <properties type="array">
              <_ type="object">
                <type>property</type>
                <nameSpace><![CDATA[{{домен.схема}}]]></nameSpace>
                <localName>misis:дата</localName>
                <value type="object"><xquery>current-dateTime()</xquery></value>
              </_>
              <_ type="object">
                <type>property</type>
                <nameSpace><![CDATA[{{домен.схема}}]]></nameSpace>
                <localName>misis:label</localName>
                <value type="object"><xquery>./table/@label/data()</xquery></value>
              </_>
              <_ type="object">
                <type>property</type>
                <nameSpace><![CDATA[{{xmlns.rdf}}]]></nameSpace>
                <localName>rdf:type</localName>
                <value><![CDATA[{{домен.онтология}}{{class.table}}]]></value>
              </_>
            </properties>
            <row type="object">
              <type>subject</type>
              <about type="object">
                <value type="object">
                  <xquery><![CDATA['{{домен.схема}}' || random:uuid()]]></xquery>
                </value>
              </about>
              <nameSpace><![CDATA[{{домен.схема}}]]></nameSpace>
              <localName>misis:свойстваСтроки</localName>
              <filter type="object">
                <value type="object">
                  <xquery>.</xquery>
                </value>
              </filter>
              <properties type="array">
                <_ type="object">
                  <type>property</type>
                  <nameSpace><![CDATA[{{xmlns.rdf}}]]></nameSpace>
                  <localName>rdf:type</localName>
                  <value><![CDATA[{{домен.онтология}}{{class.row}}]]></value>
                </_>
              </properties>
              <cell type="object">
                <properties type="array">{$поля}</properties>
              </cell>
            </row>
          </table>
        </schema>
      </json>
    )
};