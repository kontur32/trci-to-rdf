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

## Сценарий работы со схемами

1. [автоматически сгенерировать схему](xq/generate-schema.xq), из которой получится такой [RDF](example/RDF/RDF-example.xml), из которого можно извлечь данные вот таким [SPARQL-запросом](example/SPARQL/SPARQL-example.rq)
1. в схеме явно указать имена свойств ([модификация схемы 1](example/schemas/schema-example-1.json)), из которой получится такой [RDF](example/RDF/RDF-example-1.xml), из которого можно извлечь данные вот таким [SPARQL-запросом](example/SPARQL/SPARQL-example1.rq)
1. добавить в схему инструкции для обработки "сложных полей" и фильтры для исключения полей с нерелевантными значениями ([модификация схемы 2](example/schemas/schema-example-2.json)), из которой получится такой [RDF](example/RDF/RDF-example-2.xml), из которого можно извлечь данные вот таким [SPARQL-запросом](example/SPARQL/SPARQL-example-2.rq)
1. сделать схемы для отдельных таблиц эксель-файла, опубликовать их вместе с файлами с изменямиыми параметрами сехмы (в схеме в двойных фигурных скобках {{}}), и разместить ссылки на схемы и на файлы с параметрами схем в [общей схеме для обработке файла](example/schemas/schema-file-example.json); в результате получится такой [RDF](example/RDF/RDF-example-3-file.xml), из которого можно извлечь данные вот таким [SPARQL-запросом](example/SPARQL/SPARQL-example-3.rq)
