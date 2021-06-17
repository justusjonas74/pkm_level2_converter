Gem::Specification.new do |s|
  s.name        = 'pkmlevel2'
  s.version     = '0.0.3'
  s.summary     = "Konvertiert Kontrollmodule nach VDV-KA von Level-3 nach Level-2"
  s.description = "Konvertiert Kontrollmodule nach VDV-KA von Level-3 nach Level-2"
  s.authors     = ["Francis Doege"]
  s.email       = 'hello@francisdoege.com'
  s.files       = [
                    "lib/pkmlevel2.rb",
  #                  "lib/conv_PV_KM.rb",
  #                  "lib/conv_RN_TM.rb",
                    "lib/pkmlevel2/ka/pkm/1/XML-Schema_PKM_TX.xsd",
                    "lib/pkmlevel2/ka/pkm/1/XML-Schema_PKM.xsd",
                    "lib/pkmlevel2/ka/pkm/2/XML-Schema_PKM_TX.xsd",
                    "lib/pkmlevel2/ka/pkm/2/XML-Schema_PKM_TX.xsd.MD5",
                    "lib/pkmlevel2/ka/pkm/2/XML-Schema_PKM.xsd",
                    "lib/pkmlevel2/ka/pkm/2/XML-Schema_PKM.xsd.MD5",
                  ]
  s.executables << 'pkmlevel2'
  # s.homepage    =
  #   'https://rubygems.org/gems/hola'
  s.license       = 'MIT'
end