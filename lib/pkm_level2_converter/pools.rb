require_relative 'types'
# Generische Pool-Klasse

class Pool
  # MOVED TO PKM-Class
  def self.parsePool(xml_node, pathOfPool, typeOfPool)
    # pool = @@pools[poolSymbol]
    node = xml_node.at_xpath(pathOfPool)
    typeOfPool.new(node)
  end

  def initialize(xml_node, type)
    @type = type
    @key = xml_node['key'].to_i
    @children = xml_node.children
    @items = @children.map.with_index { |parameter, index| type.new(parameter, @key, index) }
  end

  attr_reader :items, :key

  def getByReference(key)
    @items.find { |item| item.key == key }
  end
end

# Spezifische Pool-Klassen

class AusgangskontextPool < Pool
  @@type = Ausgangskontext
  def initialize(xml_node)
    super(xml_node, @@type)
  end
end

class AusgangsparameterPool < Pool
  # TODO... Das passt noch nicht zur Pool-Implementierung
  @@type = Ausgangsparameter
  def initialize(xml_node)
    super(xml_node, @@type)
  end
end

class AusgangsschnittstellenPool
  @@type = Ausgangsschnittstelle
  def initialize(xml_node)
    super(xml_node, @@type)
  end

  def cr374
    @items.select { |asst| asst.cr374? }
  end

  def cr374?
    (cr374.length != 0)
  end
end
