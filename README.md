# trci-to-rdf

трансформатор данных модели trci в RDF/XML

## Структура репозитория

Папки:  
    - `lib` - модули для генерации rdf из trci и генерации схемы по структуре trci  
    - `example` - примеры данных (входных и выходных)  
    - `xq` - скрипты для запуска примеров  

## Примеры запуска

- `lib/schema.xq` из файла `xlsx` автоматически генерирует [шаблон схемы](/example/schemas/schema-example.json)
- `lib/rdf-from-xlsx.xq` из файла `xlsx` автоматически генерирует [RDF/XML](/example/RDF/RDF-example.xml)
- `lib/rdf-from-xlsx-with-params.xq` из файла `xlsx`, применяя файл с параметрами ([params-example.json](/example/params-example.json)), автоматически генерирует RDF/XML
- `lib/table-to-rdf.xq` на основе [готовой схемы таблицы](/example/schemas/schema-example-2.json) из файла `xlsx` генерирует [RDF/XML](/example/RDF/RDF-example-2.xml)
- `lib/trci-file-to-rdf.xq` на основе [готовой схемы файла](/example/schemas/schema-file-example.json) из  файла из файла `xlsx` генерирует такой [RDF/XML](/example/RDF/RDF-example-3-file.xml)

## Примеры работы со схемами

1. [Реестр преметов (самый простой)](/docs/Реестр-предметов.md)
1. [Анкета преподавателя (чуть сложнее)](/docs/Анкета-преподавателя.md)
