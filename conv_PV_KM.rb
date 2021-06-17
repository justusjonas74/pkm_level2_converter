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
  #xsd =  File.read("./ka/pkm/1/XML-Schema_PKM.xsd")
  file_path = File.join(File.dirname(__FILE__), './ka/pkm/1/XML-Schema_PKM.xsd') 
  xsd =  File.read(file_path)
  return check_xsd(xsd,xml)
end

def convert_xpath_l3_id(node, x_path)
  map = node.at_xpath x_path
  id = map.content.to_i
  map.content = (id + 0x8000).to_s
end

def convert_ids
  #Organisations-ID des DL: 
  #dl-km/organisation/id
  # convert_xpath_l3_id(@xml_doc, 'xmlns:dl-km/xmlns:organisation/xmlns:id')
  # puts "Converted following IDs:"
  # puts "/dl-km/organisation/id = " + @xml_doc.xpath('/xmlns:dl-km/xmlns:organisation/xmlns:id').text
  
  # @xml_doc.xpath('/xmlns:dl-km/xmlns:kontrollmodul-pool/xmlns:item').each do |node|
    node = @xml_doc.xpath('/xmlns:pv-km')
    #Organisations-ID des PV:
    #dl-km/kontrollmodul-pool/item/moduldaten/organisation/id
    # convert_xpath_l3_id(node, '/xmlns:pv-km/xmlns:organisation/xmlns:id')
    convert_xpath_l3_id(node, 'xmlns:organisation/xmlns:id')
    puts "# pv-km/organisation/id = " + node.xpath('xmlns:organisation/xmlns:id').text
    #Für PVKM zulässige Organisations-IDs der DL:
    #dl-km/kontrollmodul-pool/item/moduldaten/organisation-pool/item/id
    node.xpath('xmlns:organisation-pool/xmlns:item').each do |child| 
      convert_xpath_l3_id(child, 'xmlns:id')
      puts "## pv-km/organisation-pool/item/id = " + child.xpath('xmlns:id').text
    end
  # end
  #Für Anzeige von KVP als Klartext:
  #dl-km/kontrollmodul-pool/item/moduldaten/nummerninterpretation-pool/item[nr=2]/nummerntext-pool/item/nr
end

orig_file_name = ARGV.first
convert_pkm(orig_file_name)

