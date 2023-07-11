# Generische Klasse Poolelement

class Poolelement
    def initialize(key, index)
        @key =  key + index
    end 

    attr_reader :key
end

# Pool-Elemente

class Ausgangsparameter < Poolelement
    def initialize(node, index, key)
        super(key, index)
        @nr = node.at("./xmlns:nr").text.to_i
        @name = node.at("./xmlns:name").text
    end
end

class Ausgangsschnittstelle < Poolelement
    def initialize(asst, key, index)
        super(key, index)
        @nr = asst.at("nr").text.to_i
        @name = asst.at("name").text
        @parameterPoolRaw =asst.at_xpath('//xmlns:parameter-pool')
        @parameterPool = AusgangsparameterPool.new(@parameterPoolRaw)  
    end
    def cr374? 
        return (@nr == 3 || @nr == 4)
    end 
end



class Sprache < Poolelement
    def initialize(asst, key, index)
        super(key, index)
        @nr = asst.at("nr").text.to_i
        @name = asst.at("name").text
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