# frozen_string_literal: true
require 'nokogiri'
require 'pathname'
require_relative "pkm_level2_converter/version"

module PkmLevel2Converter
  class Error < StandardError; end
  class Converter
    def initialize(file_name)
      @filename = file_name
    end

    def filename
      @filename
    end
  
    def convertFileName()
      pn = Pathname.new(@filename)
      dir, base = File.split(pn)
      f = base.split('_')
      org_id_l3 = f[1].to_i
      org_id_l2 = org_id_l3 + 0x8000 
      f[1] = org_id_l2.to_s
      return Pathname.new(dir).join(f.join("_"))
    end
  
    def save_file(file)
      #SAVE FILE with NEW name
      new_file_name = self.convertFileName()
      output = File.open( new_file_name, "w" )
      output << file.to_xml(:indent_text => "", :indent => 0).gsub(/>\n/,">")
      output.close
      puts "File saved as: #{new_file_name}"  
    end
  
    def check_xsd(xsd, xml)
      puts "Check XML-Schema..."
      xsd = Nokogiri::XML::Schema(xsd)
      error = xsd.validate(xml)
      if error.empty? 
        puts "XML-Schema is valid."
        return true
      else
        puts "XML-Schema is invalid."
        error.each do |e|
          puts e.message
        end
        return false
      end
    end
  
    def convert_pkm()
      orig_file_name = @filename
      if File.file?(orig_file_name) 
        @xml_doc = File.open(orig_file_name) { |f| Nokogiri::XML(f) }
        case @xml_doc.root.name
        when "pv-km"
          convert_ids_pvkm
        when "dl-km"
          convert_ids_dlkm
        when "rntm"
          convert_ids_rntm
        else
          puts(@xml_doc.root.name + " wird nicht unterstützt.")
        end

        if xml_is_valid_pkm(@xml_doc) 
          save_file(@xml_doc)
        end
      else 
        puts "File ('#{orig_file_name}') not found."    
      end
    end
  
    def xml_is_valid_pkm(xml)
      #xsd =  File.read("./ka/pkm/1/XML-Schema_PKM.xsd")
      path=''
      case @xml_doc.root.name
      when "pv-km"
        path = './pkm_level2_converter/ka/pkm/1/XML-Schema_PKM.xsd'
      when "dl-km"
        path = './pkm_level2_converter/ka/pkm/1/XML-Schema_PKM.xsd'
      when "rntm"
        path = './pkm_level2_converter/ka/pkm/2/XML-Schema_PKM.xsd'
      end

      file_path = File.join(File.dirname(__FILE__), path) 
  
      xsd =  File.read(file_path)
      return self.check_xsd(xsd,xml)
    end
  
    def convert_xpath_l3_id(node, x_path)
      map = node.at_xpath x_path
      id = map.content.to_i
      map.content = (id + 0x8000).to_s
    end
  
    def convert_ids_dlkm
      #Organisations-ID des DL: 
      #dl-km/organisation/id
      convert_xpath_l3_id(@xml_doc, 'xmlns:dl-km/xmlns:organisation/xmlns:id')
      puts "Converted following IDs:"
      puts "/dl-km/organisation/id = " + @xml_doc.xpath('/xmlns:dl-km/xmlns:organisation/xmlns:id').text
      
      @xml_doc.xpath('/xmlns:dl-km/xmlns:kontrollmodul-pool/xmlns:item').each do |node|
      
        #Organisations-ID des PV:
        #dl-km/kontrollmodul-pool/item/moduldaten/organisation/id
        convert_xpath_l3_id(node, 'xmlns:moduldaten/xmlns:organisation/xmlns:id')
        puts "# dl-km/kontrollmodul-pool/item/moduldaten/organisation/id = " + node.xpath('xmlns:moduldaten/xmlns:organisation/xmlns:id').text
        #Für PVKM zulässige Organisations-IDs der DL:
        #dl-km/kontrollmodul-pool/item/moduldaten/organisation-pool/item/id
        node.xpath('xmlns:moduldaten/xmlns:organisation-pool/xmlns:item').each do |child| 
          convert_xpath_l3_id(child, 'xmlns:id')
          puts "## dl-km/kontrollmodul-pool/item/moduldaten/organisation-pool/item/id = " + child.xpath('xmlns:id').text
        end
      end
      #Für Anzeige von KVP als Klartext:
      #dl-km/kontrollmodul-pool/item/moduldaten/nummerninterpretation-pool/item[nr=2]/nummerntext-pool/item/nr
    end

    def convert_ids_pvkm
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
    
    def convert_ids_rntm
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

  end
  
end
