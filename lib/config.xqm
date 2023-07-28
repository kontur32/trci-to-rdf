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
