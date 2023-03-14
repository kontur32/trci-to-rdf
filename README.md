# trci-to-rdf

трансформатор данных модели trci в RDF/XML

## Структура репозитория

Папки:  
    - `lib` - модули для генерации rdf из trci и генерации схемы по структуре trci  
    - `example` - примеры данных (входных и выходных)  
    - `xq` - скрипты для запуска примеров  

## Примеры запуска

- `lib/generate-schema.xq` получится такой [шаблон схемы](example/schemas/schema-example.json)
- `lib/generate-rdf.xq` из [файла trci](example/TRCI/TRCI-example.xml) автоматически [RDF/XML](example/RDF/RDF-example.xml)
- `lib/generate-trci-table-to-rdf.xq` на основе [готовой схемы](example/schemas/schema-example-2.json) для одной таблицы из такого [файла trci](example/TRCI/TRCI-example.xml) получится такой [RDF/XML](example/RDF/RDF-example-2.xml)
- `lib/generate-trci-file-to-rdf.xq` на основе [готовой схемы](example/schemas/schema-file-example.json) для  файла из такого [файла trci](example/TRCI/TRCI-example.xml) получится такой [RDF/XML](example/RDF/RDF-example-3-file.xml)

## Примеры работы со схемами

1. [Реестр преметов (самый простой)](docs/Реестр-предметов.md)
1. [Анкета преподавателя (чуть сложнее)](docs/Анкета-преподавателя.md)

