# frozen_string_literal: true

require_relative 'pools'
require 'pry'

# Main Class
class PKM
  def self.parse_pool(xml, pool_symbol)
    pool = PKM.pools[pool_symbol]
    path_of_pool = pool[:path_of_pool]
    type_of_pool = pool[:type_of_pool]
    Pool.parse_pool(xml, path_of_pool, type_of_pool)
  end

  def self.pools
    {
      ausgangskontext_pool: {
        path_of_pool: '//xmlns:rntm/xmlns:ausgangskontext-pool | //xmlns:dl-km/xmlns:ausgangskontext-pool',
        type_of_pool: AusgangskontextPool
      },
      ausgangsschnittstellen_pool: {
        path_of_pool: '//xmlns:rntm/xmlns:ausgangsschnittstelle-pool | //xmlns:dl-km/xmlns:ausgangsschnittstelle-pool',
        type_of_pool: AusgangsschnittstellenPool
      },
      sprache_pool: {
        path_of_pool: '//xmlns:rntm/xmlns:sprache-pool | //xmlns:dl-km/xmlns:sprache-pool',
        type_of_pool: SprachePool
      }
    }
  end

  def initialize(pkm_xml)
    @xml_doc = pkm_xml
    @sprache_pool = PKM.parse_pool(@xml_doc, :sprache_pool)
    @ausgangsschnittstellen_pool = PKM.parse_pool(@xml_doc, :ausgangsschnittstellen_pool)
    @ausgangskontext_pool = PKM.parse_pool(@xml_doc, :ausgangskontext_pool)
  end

  attr_reader :ausgangskontext_pool, :ausgangsschnittstellen_pool, :xml_doc

  def cr374?
    return false if @ausgangsschnittstellen_pool.nil? || @ausgangsschnittstellen_pool.empty?

    @ausgangsschnittstellen_pool.cr374?
  end

  def ermittle_alle_cr374_ausgangskontexte
    asst_pool = @ausgangsschnittstellen_pool.cr374
    puts "Es wurde #{asst_pool.length} Schnittstelle(n) nach CR 374 gefunden"
    ausgangskontexte = asst_pool.to_set.collect! do |asst|
      puts "\nAusgangsschnittstelle #{asst.nr} (\"#{asst.name}\") mit #{asst.parameter_pool.length} Ausgangsparametern:"
      asst.ermittle_alle_cr374_ausgangskontexte_zu_ausgangsparametern(ausgangskontext_pool)
    end
    ausgangskontexte.flatten
  end
end
