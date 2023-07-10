# Pool-Elemente

class Ausgangsparameter
    def initialize(node, index, key)
        @key = key + index
        @nr = node.at("./xmlns:nr").text.to_i
        @name = node.at("./xmlns:name").text
    end
end

class Ausgangsschnittstelle
    def initialize(asst, key, index)
        @key =  key + index
        @nr = asst.at("nr").text.to_i
        @name = asst.at("name").text
        @parameterPoolRaw =asst.at_xpath('//xmlns:parameter-pool')
        @parameterPool = AusgangsparameterPool.new(@parameterPoolRaw)  
    end
    def cr374? 
        return (@nr == 3 || @nr == 4)
    end 
end

# <ausgangskontext-pool key="10">
#   <item>
#       <name>AK-Deutschlandticket-PV</name>
#   <sprache>
# <ref>3</ref>
# </sprache>
# <parameter>
# <ref>5</ref>
# <ref>6</ref>
# <ref>7</ref>
# <ref>8</ref>
# <ref>9</ref>
# </parameter>
# </item>
# </ausgangskontext-pool>


class Ausgangskontext 
    def initialize(node, index, key)
      @key = key + index 
      @name = node.at("./xmlns:name").text
    end
    attr_reader :key
  end
  
class Sprache
end