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
  генерирует полный путь
:)
declare function config:setPath($path as xs:string) as xs:string {
  starts-with($path, '/') ?? $path !! config:rootPath() || $path
};

(:
  генерирует путь к папке пользователя с файлами в контейнере nextcloud
:)
declare function config:rootPath() as xs:string {
  let $domain := replace(request:hostname(), '^data\.', '')
  let $user := config:param('user') ?? config:param('user') !! $domain
  return
    config:param('rootPath') || $user || '/files/' || $domain || '/'
}; 

(:
  извлекает имя домена из хоста в запросе
:)
declare function config:dataDomain() as xs:string {
  replace(request:hostname(), '^data\.', '')
}; 