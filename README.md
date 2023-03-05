# trci-to-rdf
трансформатор данных модели trci в RDF/XML
    
## Структура репозитория:  
Папки:  
    - `lib` - модули для генерации rdf из trci и генерации схемы по структуре trci  
    - `example` - примеры данных (входных и выходных)  
    - `xq` - скрипты для запуска примеров  

## Примеры запуска

Сгенерировать:
- `lib/generate-schema.xq` получится такой [шаблон схемы](example/schemas/schema-example.json)
- `lib/generate-rdf.xq` из [файла trci](example/TRCI/TRCI-example.xml) автоматически [RDF/XML](example/RDF/RDF-auto-generate.xml) 
- `lib/generate-rdf-with-schema.xq` на основе [готовой схемы](example/schemas/modified-schema-example-resource.json) из такого [файла trci](example/TRCI/TRCI-example.xml) получится такой [RDF/XML](example/RDF/RDF-modified-schema-example-resource.xml)

## Сценарий работы со схемами  
1. [автоматически сгенерировать схему](xq/generate-schema.xq), из которой получится такой [RDF](example/RDF/RDF-auto-generate.xml), из которого можно извлечь данные вот таким [SPARQL запросом](example/SPARQL/SPARQL-example.rq)
1. в схеме явно указать имена свойств ([модификация схемы 1](example/schemas/modified-schema-example.json)), из которой получится такой [RDF](example/RDF/RDF-modified-schema-example.xml), из которого можно извлечь данные вот таким [SPARQL запросом](example/SPARQL/SPARQL-example1.rq)
1. добавить в схему инструкции для обработки "сложных полей" и фильтры для исключения полей с нерелевантными значениями ([модификация схемы 2](example/schemas/modified-schema-example-resource.json)), из которой получится такой [RDF](example/RDF/RDF-modified-schema-example-resource.xml), из которого можно извлечь данные вот таким [SPARQL запросом](example/SPARQL/SPARQL-example2.rq)