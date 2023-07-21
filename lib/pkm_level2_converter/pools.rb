# frozen_string_literal: true

require_relative 'types'

# Generische Pool-Klasse
class Pool
  # MOVED TO PKM-Class
  def self.parse_pool(xml_node, path_of_pool, type_of_pool)
    # pool = @@pools[poolSymbol]
    node = xml_node.at_xpath(path_of_pool)
    type_of_pool.new(node)
  end

  def initialize(xml_node, type)
    @type = type
    @key = xml_node['key'].to_i
    children = xml_node.children
    @items = children.map.with_index { |parameter, index| type.new(parameter, @key, index) }
  end

  attr_reader :items, :key

  def get_by_reference(key)
    @items.find { |item| item.key == key }
  end

  def empty?
    (@items.nil? || @items.empty?)
  end

  def length
    @items.length
  end
end

# Spezifische Pool-Klassen

# Ein XML-Ausgangskontext-Pool kodiert die Auflistung aller Ausgangskontext einesTarifmoduls.
class AusgangskontextPool < Pool
  def self.type
    Ausgangskontext
  end

  def initialize(xml_node)
    super(xml_node, AusgangskontextPool.type)
  end

  def get_by_parameter(parameter)
    @items.select { |ausgangskontext| ausgangskontext.contains_parameter?(parameter) }
  end
end

# Ein XML-Ausgangsparameter-Poolkodiert die Auflistung allerAusgangsparametereinerAusgangsschnittstelle.
class AusgangsparameterPool < Pool
  # TODO... Das passt noch nicht zur Pool-Implementierung
  def self.type
    Ausgangsparameter
  end

  def initialize(xml_node)
    super(xml_node, AusgangsparameterPool.type)
  end
end

# Ein XML-Ausgangsschnittstelle-Poolkodiert die Auflistung allerAusgangsschnittstellen einesTarifmoduls.
class AusgangsschnittstellenPool < Pool
  def self.type
    Ausgangsschnittstelle
  end

  def initialize(xml_node)
    super(xml_node, AusgangsschnittstellenPool.type)
  end

  def cr374
    @items.select(&:cr374?)
  end

  # def cr374_asst_pool_set
  #   cr374.to_set
  # end

  def cr374?
    !cr374.empty?
  end
end

# Ein XML-Sprache-Pool kodiert die Auflistung aller unterstützten Sprachen eines Tarifmoduls.
class SprachePool < Pool
  def self.type
    Sprache
  end

  def initialize(xml_node)
    super(xml_node, SprachePool.type)
  end
end
