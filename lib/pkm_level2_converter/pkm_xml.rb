# frozen_string_literal: true

require 'nokogiri'
require 'pathname'

# XML-Klasse zu einem PKM
class PKMXml
  def self.convert_xpath_l3_id(node, x_path)
    map = node.at_xpath x_path
    id = map.content.to_i
    map.content = (id + 0x8000).to_s
  end

  def self.check_xsd(xsd, xml)
    puts 'Check XML-Schema...'
    xsd = Nokogiri::XML::Schema(xsd)
    error = xsd.validate(xml)
    if error.empty?
      puts 'XML-Schema is valid.'
      true
    else
      puts 'XML-Schema is invalid.'
      error.each do |e|
        puts e.message
      end
      false
    end
  end

  def self.xml_is_valid_pkm(xml)
    # xsd =  File.read("./ka/pkm/1/XML-Schema_PKM.xsd")
    path = ''
    case xml.root.name
    when 'pv-km', 'dl-km'
      path = './ka/pkm/1/XML-Schema_PKM.xsd'
    when 'rntm'
      path = './ka/pkm/2/XML-Schema_PKM.xsd'
    end

    file_path = File.join(File.dirname(__FILE__), path)

    xsd = File.read(file_path)
    PKMXml.check_xsd(xsd, xml)
  end

  def initialize(file_name)
    @filename = file_name
    is_a_file = File.file?(@filename)
    puts "File ('#{@filename}') not found." unless is_a_file
    return unless is_a_file

    @xml_doc = File.open(@filename) { |f| Nokogiri::XML(f) }
    # Is it a valid PKM file?
    xml_is_invalid_pkm = (@xml_doc.nil? || !valid_xml?)
    puts 'File is not a valid PKM file' if xml_is_invalid_pkm
    return if xml_is_invalid_pkm

    @pkm_data = PKM.new(@xml_doc)
  end

  attr_reader :pkm_data

  def convert_file_name
    pn = Pathname.new(@filename)
    dir, base = File.split(pn)
    f = base.split('_')
    org_id_l3 = f[1].to_i
    org_id_l2 = org_id_l3 + 0x8000
    f[1] = org_id_l2.to_s
    Pathname.new(dir).join(f.join('_'))
  end

  def convert_org_id_to_level2
    case @xml_doc.root.name
    when 'pv-km'
      convert_ids_pvkm
    when 'dl-km'
      convert_ids_dlkm
    when 'rntm'
      convert_ids_rntm
    else
      puts("#{@xml_doc.root.name} wird nicht unterstützt.")
    end

    convert_ids_cr374
    # binding.pry
    save_file
  end

  def valid_xml?
    PKMXml.xml_is_valid_pkm(@xml_doc)
  end

  def save_file
    # file = @filename
    file = @xml_doc
    return unless valid_xml?

    # SAVE FILE with NEW name
    new_file_name = convert_file_name
    output = File.open(new_file_name, 'w')
    output << file.to_xml(indent_text: '', indent: 0).gsub(">\n", '>')
    output.close
    puts "File saved as: #{new_file_name}"
  end

  def convert_ids_dlkm
    # Organisations-ID des DL:
    # dl-km/organisation/id
    PKMXml.convert_xpath_l3_id(@xml_doc, 'xmlns:dl-km/xmlns:organisation/xmlns:id')
    puts 'Converted following IDs:'
    puts "/dl-km/organisation/id = #{@xml_doc.xpath('/xmlns:dl-km/xmlns:organisation/xmlns:id').text}"

    @xml_doc.xpath('/xmlns:dl-km/xmlns:kontrollmodul-pool/xmlns:item').each do |node|
      # Organisations-ID des PV:
      # dl-km/kontrollmodul-pool/item/moduldaten/organisation/id
      PKMXml.convert_xpath_l3_id(node, 'xmlns:moduldaten/xmlns:organisation/xmlns:id')
      org_id_text = node.xpath('xmlns:moduldaten/xmlns:organisation/xmlns:id').text
      puts "# dl-km/kontrollmodul-pool/item/moduldaten/organisation/id = #{org_id_text}"
      # Für PVKM zulässige Organisations-IDs der DL:
      # dl-km/kontrollmodul-pool/item/moduldaten/organisation-pool/item/id
      node.xpath('xmlns:moduldaten/xmlns:organisation-pool/xmlns:item').each do |child|
        PKMXml.convert_xpath_l3_id(child, 'xmlns:id')
        puts "## dl-km/kontrollmodul-pool/item/moduldaten/organisation-pool/item/id = #{child.xpath('xmlns:id').text}"
      end
    end
    # Für Anzeige von KVP als Klartext:
    # dl-km/kontrollmodul-pool/item/moduldaten/nummerninterpretation-pool/item[nr=2]/nummerntext-pool/item/nr
  end

  def convert_ids_rntm
    # Organisations-ID des RN:
    # rntm/herausgeber/nr
    PKMXml.convert_xpath_l3_id(@xml_doc, 'xmlns:rntm/xmlns:herausgeber/xmlns:nr')
    puts 'Converted following IDs:'
    puts "rntm/herausgeber/nr = #{@xml_doc.xpath('xmlns:rntm/xmlns:herausgeber/xmlns:nr').text}"

    @xml_doc.xpath('/xmlns:rntm/xmlns:tarifmodul-pool/xmlns:item').each do |node|
      # Organisations-ID des PV:
      # dl-km/kontrollmodul-pool/item/moduldaten/organisation/id

      PKMXml.convert_xpath_l3_id(node, 'xmlns:tarifmodul/xmlns:herausgeber/xmlns:nr')
      herausgeber_org_id = node.xpath('xmlns:tarifmodul/xmlns:herausgeber/xmlns:nr').text
      puts "# /rntm/tarifmodul-pool/item/tarifmodul/herausgeber/nr/ = #{herausgeber_org_id}"
      # Für PVKM zulässige Organisations-IDs der DL:
      # dl-km/kontrollmodul-pool/item/moduldaten/organisation-pool/item/id
      node.xpath('xmlns:tarifmodul/xmlns:organisation-pool/xmlns:item').each do |child|
        PKMXml.convert_xpath_l3_id(child, 'xmlns:nr')
        puts "## /rntm/tarifmodul-pool/item/tarifmodul/organisation-pool/item/nr = #{child.xpath('xmlns:nr').text}"
      end
    end
    # Für Anzeige von KVP als Klartext:
    # dl-km/kontrollmodul-pool/item/moduldaten/nummerninterpretation-pool/item[nr=2]/nummerntext-pool/item/nr
  end

  def convert_ids_pvkm
    # Organisations-ID des DL:
    # dl-km/organisation/id
    # PKM.convert_xpath_l3_id(@xml_doc, 'xmlns:dl-km/xmlns:organisation/xmlns:id')
    # puts "Converted following IDs:"
    # puts "/dl-km/organisation/id = " + @xml_doc.xpath('/xmlns:dl-km/xmlns:organisation/xmlns:id').text

    # @xml_doc.xpath('/xmlns:dl-km/xmlns:kontrollmodul-pool/xmlns:item').each do |node|
    node = @xml_doc.xpath('/xmlns:pv-km')
    # Organisations-ID des PV:
    # dl-km/kontrollmodul-pool/item/moduldaten/organisation/id
    # PKM.convert_xpath_l3_id(node, '/xmlns:pv-km/xmlns:organisation/xmlns:id')
    PKMXml.convert_xpath_l3_id(node, 'xmlns:organisation/xmlns:id')
    puts "# pv-km/organisation/id = #{node.xpath('xmlns:organisation/xmlns:id').text}"
    # Für PVKM zulässige Organisations-IDs der DL:
    # dl-km/kontrollmodul-pool/item/moduldaten/organisation-pool/item/id
    node.xpath('xmlns:organisation-pool/xmlns:item').each do |child|
      PKMXml.convert_xpath_l3_id(child, 'xmlns:id')
      puts "## pv-km/organisation-pool/item/id = #{child.xpath('xmlns:id').text}"
    end
    # end
    # Für Anzeige von KVP als Klartext:
    # dl-km/kontrollmodul-pool/item/moduldaten/nummerninterpretation-pool/item[nr=2]/nummerntext-pool/item/nr
  end

  def convert_ids_cr374
    ## Ist die Ausgangsschnittstelle 3 bzw. 4 im Kontrollmodul vorhanden?
    return unless @pkm_data.cr374?

    puts 'CR374 ist umgesetzt. OrgIDs werden angepasst.'
  end
end
