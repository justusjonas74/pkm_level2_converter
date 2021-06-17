require 'nokogiri'
require 'pry'
require_relative 'check_xsd'

def convertFileName(file_name)
  f = file_name.split('_')
  org_id_l3 = f[1].to_i
  org_id_l2 = org_id_l3 + 0x8000 
  f[1] = org_id_l2.to_s
  return f.join("_")
end

def safe_file(file, new_file_name)
  #SAVE FILE with NEW name
  output = File.open( new_file_name, "w" )
  output << file.to_xml(:indent_text => "", :indent => 0).gsub(/>\n/,">")
  output.close
  puts "File saved as: #{new_file_name}"  
  
end

def convert_pkm(orig_file_name)
  if File.file?(orig_file_name) 
    new_file_name = convertFileName(orig_file_name)
    @xml_doc = File.open(orig_file_name) { |f| Nokogiri::XML(f) }
    convert_ids
    if xml_is_valid_pkm(@xml_doc) 
      safe_file(@xml_doc, new_file_name)
    end
  else 
    puts "File ('#{orig_file_name}') not found."    
  end
end

def xml_is_valid_pkm(xml)
  xsd =  File.read("ka/pkm/2/XML-Schema_PKM.xsd")
  return check_xsd(xsd,xml)
end

def convert_xpath_l3_id(node, x_path)
  map = node.at_xpath x_path
  id = map.content.to_i
  map.content = (id + 0x8000).to_s
end

def convert_ids
  #Organisations-ID des RN: 
  #rntm/herausgeber/nr
  convert_xpath_l3_id(@xml_doc, 'xmlns:rntm/xmlns:herausgeber/xmlns:nr')
  puts "Converted following IDs:"
  puts "rntm/herausgeber/nr = " + @xml_doc.xpath('xmlns:rntm/xmlns:herausgeber/xmlns:nr').text
  
  @xml_doc.xpath('/xmlns:rntm/xmlns:tarifmodul-pool/xmlns:item').each do |node|
  
    #Organisations-ID des PV:
    #dl-km/kontrollmodul-pool/item/moduldaten/organisation/id
    
    convert_xpath_l3_id(node, 'xmlns:tarifmodul/xmlns:herausgeber/xmlns:nr')
    puts "# /rntm/tarifmodul-pool/item/tarifmodul/herausgeber/nr/ = " + node.xpath('xmlns:tarifmodul/xmlns:herausgeber/xmlns:nr').text
    #Für PVKM zulässige Organisations-IDs der DL:
    #dl-km/kontrollmodul-pool/item/moduldaten/organisation-pool/item/id
    node.xpath('xmlns:tarifmodul/xmlns:organisation-pool/xmlns:item').each do |child| 
      convert_xpath_l3_id(child, 'xmlns:nr')
      puts "## /rntm/tarifmodul-pool/item/tarifmodul/organisation-pool/item/nr = " + child.xpath('xmlns:nr').text
    end
  end
  #Für Anzeige von KVP als Klartext:
  #dl-km/kontrollmodul-pool/item/moduldaten/nummerninterpretation-pool/item[nr=2]/nummerntext-pool/item/nr
end

orig_file_name = ARGV.first
convert_pkm(orig_file_name)

