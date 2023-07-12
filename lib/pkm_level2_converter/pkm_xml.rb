# frozen_string_literal: true

require 'nokogiri'
require 'pathname'

# XML-Klasse zu einem PKM
class PKMXml
  def self.convert_xpath_l3_id(node, x_path)
    map = node.at_xpath x_path
    id = map.content.to_i
    map.content = (id + 0x8000).to_s
    puts "#{map.path.gsub('xmlns:', '')} = #{map.text}"
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
    return unless valid_xml?

    # SAVE FILE with NEW name
    new_file_name = convert_file_name
    output = File.open(new_file_name, 'w')
    output << @xml_doc.to_xml(indent_text: '', indent: 0).gsub(">\n", '>')
    output.close
    puts "File saved as: #{new_file_name}"
  end

  def type
    case @xml_doc.root.name
    when 'pv-km'
      :pv_km
    when 'dl-km'
      :dl_km
    when 'rntm'
      :rn_tm
    else
      puts("#{@xml_doc.root.name} wird nicht unterstützt.")
      nil
    end
  end

  def self.pathes
    {
      dl_km: {
        herausgeber_xpath: '/xmlns:dl-km/xmlns:organisation/xmlns:id',
        enthaltene_pvmodule_xpath: '/xmlns:dl-km/xmlns:kontrollmodul-pool/xmlns:item',
        herausgeber_enthaltene_pvmodule_xpath: 'xmlns:moduldaten/xmlns:organisation/xmlns:id',
        zulaessige_organisationen_xpath: 'xmlns:moduldaten/xmlns:organisation-pool/xmlns:item',
        zulaessige_organisationen_org_id_xpath: 'xmlns:id'
      },
      pv_km: {
        herausgeber_xpath: '/xmlns:pv-km/xmlns:organisation/xmlns:id',
        enthaltene_pvmodule_xpath: '.',
        herausgeber_enthaltene_pvmodule_xpath: nil,
        zulaessige_organisationen_xpath: 'xmlns:organisation-pool/xmlns:item',
        zulaessige_organisationen_org_id_xpath: 'xmlns:id'
      },
      rn_tm: {
        herausgeber_xpath: '/xmlns:rntm/xmlns:herausgeber/xmlns:nr',
        enthaltene_pvmodule_xpath: '/xmlns:rntm/xmlns:tarifmodul-pool/xmlns:item',
        herausgeber_enthaltene_pvmodule_xpath: 'xmlns:tarifmodul/xmlns:herausgeber/xmlns:nr',
        zulaessige_organisationen_xpath: 'xmlns:tarifmodul/xmlns:organisation-pool/xmlns:item',
        zulaessige_organisationen_org_id_xpath: 'xmlns:nr'
      }
    }
  end

  def path_to(symbol)
    PKMXml.pathes.dig type, symbol
  end

  def convert_orgid_at_path(symbol, node)
    path = path_to(symbol)
    PKMXml.convert_xpath_l3_id(node, path) if path
  end

  def iterate_on_xpath(symbol, node, &block)
    iterator_path = path_to(symbol)
    node.xpath(iterator_path).each { |element| block.call(element) }
  end

  def convert_herausgeber
    convert_orgid_at_path(@xml_doc, :herausgeber_xpath)

    iterate_on_xpath(:enthaltene_pvmodule_xpath, node) do |pvmodul|
      convert_orgid_at_path(pvmodul, :herausgeber_enthaltene_pvmodule_xpath)

      iterate_on_xpath(:zulaessige_organisationen_xpath, pvmodul) do |organisation|
        convert_orgid_at_path(organisation, :zulaessige_organisationen_org_id_xpath)
      end
    end
  end

  def convert_ids_cr374
    ## Ist die Ausgangsschnittstelle 3 bzw. 4 im Kontrollmodul vorhanden?
    return unless @pkm_data.cr374?

    puts 'CR374 ist umgesetzt. OrgIDs werden angepasst.'
  end
end
