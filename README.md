# trci-to-rdf

трансформатор данных модели trci в RDF/XML

## Структура репозитория

Папки:  
    - `lib` - модули для генерации rdf из trci и генерации схемы по структуре trci  
    - `example` - примеры данных (входных и выходных)  
    - `xq` - скрипты для запуска примеров  

## Примеры запуска

Сгенерировать:

- `lib/generate-schema.xq` получится такой [шаблон схемы](example/schemas/schema-example.json)
- `lib/generate-rdf.xq` из [файла trci](example/TRCI/TRCI-example.xml) автоматически [RDF/XML](example/RDF/RDF-example.xml)
- `lib/generate-trci-table-to-rdf.xq` на основе [готовой схемы](example/schemas/schema-example-2.json) для одной таблицы из такого [файла trci](example/TRCI/TRCI-example.xml) получится такой [RDF/XML](example/RDF/RDF-example-2.xml)
- `lib/generate-trci-file-to-rdf.xq` на основе [готовой схемы](example/schemas/schema-file-example.json) для  файла из такого [файла trci](example/TRCI/TRCI-example.xml) получится такой [RDF/XML](example/RDF/RDF-example-3-file.xml)

## Примеры работы со схемами

### Реестр преметов (самый простой)

В данном примере используется файл с [реестром предметов](example\реестр предметов\xlsx\Predmeti.xlsx)

#### Генерация RDF/XML

1. Запустить этот [скрипт](xq/generate-rdf-from-xlsx.xq) полностью автоматической генерации RDF из `xlsx`; получится вот такой [RDF/XML](example/реестр предметов/RDF/1-реестр-автоматически.rdf)
1. Создать [файл с параметрами](example/реестр предметов/params/params.json), в котором можно указать пространства имен для элементов и классов, имена префиксов, имена классов
1. С помощью [скрипта](xq/generate-rdf-from-xlsx-with-params.xq) cгенерировать [RDF/XML](example/реестр предметов/RDF/2-реестр-автоматически-с-параметрами.rdf)
1. С помощью [скрипта](xq/ggenerate-schema.xq) cгенерировать [схему](example/реестр предметов/schemas/schema-1.json) и внести в нее изменения: [схема с изменениями](example/реестр предметов/schemas/schema-2.json)
1. С помощью [скрипта](xq/generate-table-to-rdf.xq) cгенерировать [RDF/XML](example/реестр предметов/RDF/3-реестр-на-основе-схемы-2.rdf) (в скрипте указать пути к файлам:  `xlsx`, параметров, схемы)

#### Извлечение данных

Полученные RDF-файлы можно загрузить в базу. Для извлечения можно использовать такие SPARQL-запросы:

1. [SPARQL-запрос](example/реестр предметов/SPARQL/SPARQL-1.rq) к автоматически сегенерированному [RDF/XML](example/реестр предметов/RDF/1-реестр-автоматически.rdf)
1. [SPARQL-запрос](example/реестр предметов/SPARQL/SPARQL-2.rq) к [RDF/XML](example/реестр предметов/RDF/3-реестр-на-основе-схемы-2.rdf), сгенерированного с помощью такой [схемы](example/реестр предметов/schemas/schema-2.json)

### Анкета преподавателя (чуть сложнее)

1. [автоматически сгенерировать схему](xq/generate-schema.xq), из которой получится такой [RDF](example/RDF/RDF-example.xml), из которого можно извлечь данные вот таким [SPARQL-запросом](example/SPARQL/SPARQL-example.rq)
1. в схеме явно указать имена свойств ([модификация схемы 1](example/schemas/schema-example-1.json)), из которой получится такой [RDF](example/RDF/RDF-example-1.xml), из которого можно извлечь данные вот таким [SPARQL-запросом](example/SPARQL/SPARQL-example1.rq)
1. добавить в схему инструкции для обработки "сложных полей" и фильтры для исключения полей с нерелевантными значениями ([модификация схемы 2](example/schemas/schema-example-2.json)), из которой получится такой [RDF](example/RDF/RDF-example-2.xml), из которого можно извлечь данные вот таким [SPARQL-запросом](example/SPARQL/SPARQL-example-2.rq)
1. сделать схемы для отдельных таблиц эксель-файла, опубликовать их вместе с файлами с изменямиыми параметрами сехмы (в схеме в двойных фигурных скобках {{}}), и разместить ссылки на схемы и на файлы с параметрами схем в [общей схеме для обработке файла](example/schemas/schema-file-example.json); в результате получится такой [RDF](example/RDF/RDF-example-3-file.xml), из которого можно извлечь данные вот таким [SPARQL-запросом](example/SPARQL/SPARQL-example-3.rq)
1. если правильно выполнено связывание сущностей (например, таких [реестр преподавателей](example/schemas/schema-список-ппс.json) и [анкета преподавателя](example/schemas/schema-example-2.json)), то можно выполнять SPARQL-запросы, которые будут находить информацию об одной сущности по всей базе данных, например, таким [запросом](example/SPARQL/SPARQL-example-4.rq).
