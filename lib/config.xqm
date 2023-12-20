module namespace config = 'trci-to-rdf/lib/config';

declare function config:config()
  as element(config)
{
  doc("../config/config.xml")/config
};

declare function config:param($param)
  as xs:string*
{
  config:config()/param[@id=$param]/text()
};



(:
  ищет файл по маске начиная с указанного пути
:)
declare function config:filePath($mask){
  config:filePath(config:rootPath() || 'данные/', $mask)
};

declare function config:filePath($paht, $mask){
  (
    for $i in file:list($paht)
    return
      if(file:is-dir($paht || $i))
      then(config:filePath($paht|| $i, $mask))
      else($paht || $i)
  )[matches(., $mask)]
};


(:
  генерирует полный путь
:)
declare function config:setPath($path as xs:string) as xs:string {
  starts-with($path, '/') ?? $path !! config:rootPath() || $path
};

(:
  генерирует путь к папке пользователя с файлами в контейнере nextcloud
:)
declare function config:scenarioPath() as xs:string {
  let $path := 
    if(config:param('сценарии'))
    then(config:param('сценарии'))
    else('сценарии')
  return
    config:rootPath() || $path || '/'
};

(:
  генерирует путь к папке пользователя с файлами в контейнере nextcloud
:)
declare function config:rootPath() as xs:string {
  let $domain := config:dataDomain()
  let $user := config:param('user') ?? config:param('user') !! $domain
  return
    config:param('rootPath') || $user || '/files/' || $domain || '/'
}; 

(:
  извлекает имя домена из хоста в запросе
:)
declare function config:dataDomain() as xs:string {
  config:param('domain') ?? config:param('domain') !! replace(request:hostname(), '^data\.', '')
}; 