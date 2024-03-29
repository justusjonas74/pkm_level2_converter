# frozen_string_literal: true

# Generische Klasse Poolelement
class Poolelement
  class << self
    def add(instance)
      @all_instances ||= []
      @all_instances.push(instance)
    end

    def get_by_ref(ref)
      @all_instances.find { |element| element.key == ref }
    end
    attr_reader :all_instances
  end

  def initialize(key, index)
    @key = key + index
    Poolelement.add(self)
  end

  attr_reader :key
end

# Pool-Elemente

# Ein Ausgangsparameter identifiziert die Rolle einer Information, die von der Geräte-Software zur Anzeige,
# allgemeinen Ausgabe oder Steuerung verwendet wird.
class Ausgangsparameter < Poolelement
  def initialize(node, index, key)
    super(key, index)
    @nr = node.at('./xmlns:nr').text.to_i
    @name = node.at('./xmlns:name').text
  end

  attr_reader :nr, :name

  def cr374?
    (nr >= 9000 && nr <= 9999)
  end
end

# Eine Ausgangsschnittstelle identifiziert eine Schnittstelle der Geräte-Software, über welche
# Informationen von einer Strategie an die Geräte-Software übergegeben werden können.
class Ausgangsschnittstelle < Poolelement
  def initialize(asst, key, index)
    super(key, index)
    @nr = asst.at('nr').text.to_i
    @name = asst.at('name').text
    parameter_pool_raw = asst.at_xpath('//xmlns:parameter-pool')
    @parameter_pool = AusgangsparameterPool.new(parameter_pool_raw)
  end

  attr_reader :parameter_pool, :nr, :name

  def cr374?
    (@nr == 3 || @nr == 4)
  end

  def ermittle_alle_cr374_ausgangskontexte_zu_ausgangsparametern(ausgangskontext_pool)
    filtered_parameters = @parameter_pool.items.select(&:cr374?).map do |parameter|
      puts "Parameter Nr. #{parameter.nr} (\"#{parameter.name}\")"
      ausgangskontext_pool.get_by_parameter(parameter)
    end
    filtered_parameters.flatten.to_set
  end
end

# Eine Sprache beschreibt das natürliche Format, in dem eine Ausgabe an den Nutzer erfolgt.
class Sprache < Poolelement
  def initialize(asst, key, index)
    super(key, index)
    @nr = asst.at('nr').text.to_i
    @name = asst.at('name').text
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

# Ein Ausgangstext steht für eine statische Information, die von einem als-Text-ausgebbaren Datenelement im Rahmen eines
# Ausgangskontexts bereitgestellt wird.
class Ausgangskontext
  def initialize(node, index, key)
    @key = key + index
    @name = node.at('./xmlns:name').text
    @sprache = node.xpath('./xmlns:sprache/xmlns:ref').map do |sprache_ref|
      Poolelement.get_by_ref(sprache_ref.text.to_i)
    end
    @parameter = node.xpath('./xmlns:parameter/xmlns:ref').map do |parameter_ref|
      Poolelement.get_by_ref(parameter_ref.text.to_i)
    end
    # ausgangsparameter # 1..N
  end
  attr_reader :key, :name, :sprache, :parameter

  def contains_parameter?(parameter)
    @parameter.find { |p| p == parameter }
  end
end
