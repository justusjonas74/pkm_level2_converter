require 'nokogiri'

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

