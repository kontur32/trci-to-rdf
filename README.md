# trci-to-rdf
трансформатор данных модели trci в RDF/XML:
    - ываы
    - ываыв
    
## Структура репозитория:  
Папки:
    - `lib` - модули для генерации rdf из trci и генерации схемы по структуре trci  
    - `example` - примеры данных (входных и выходных)  
    - `xq` - скрипты для запуска примеров  

## Примеры запуска

Сгенерировать:
-  `lib/generate-schema.xq` [шаблон схемы](/example/schemas/schema-example.json)
- `lib/generate-rdf.xq` [автоматически RDF/XML из файла с данными в trci](example/RDF/RDF-auto-generate.xml) 
- `lib/generate-rdf-with-schema.xq` [RDF/XML на основе готовой схемы](example/RDF/RDF-auto-generate.xml) 

## Ручная доработка схемы
Схему, которая автоматически сегенерирована, можно дорабоать:
1. явно указать имена свойств ([модификация схемы 1](example/schemas/modified-schema-example.json)) и получится такой [RDF](example/RDF/RDF-modified-schema-example.xml)
1. добавить инструкции для обработки "сложных полей" и фильтры для исключения полей с нерелевантными значениями ([модификация схемы 2](example/schemas/modified-schema-example-resource.json)) и получится такой [RDF](example/RDF/RDF-modified-schema-example-resource.xml)
