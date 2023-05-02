module namespace config = 'trci-to-rdf/lib/config';

declare function config:config()
  as element(config)
{
  doc("../config/config.xml")/config
};
