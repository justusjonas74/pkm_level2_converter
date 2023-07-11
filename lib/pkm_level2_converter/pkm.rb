# frozen_string_literal: true

require_relative 'pools'
require 'pry'

# Main Class
class PKM
  def self.pools
    {
      ausgangskontext_pool: {
        path_of_pool: '//xmlns:rn-tm/xmlns:ausgangskontext-pool | //xmlns:dl-km/xmlns:ausgangskontext-pool',
        type_of_pool: AusgangskontextPool
      },
      ausgangsschnittstellen_pool: {
        path_of_pool: '//xmlns:rn-tm/xmlns:ausgangsschnittstelle-pool | //xmlns:dl-km/xmlns:ausgangsschnittstelle-pool',
        type_of_pool: AusgangsschnittstellenPool
      }
      # Sprachen
    }
  end

  def self.parse_pool(xml, pool_symbol)
    pool = PKM.pools[pool_symbol]
    path_of_pool = pool[:path_of_pool]
    type_of_pool = pool[:type_of_pool]
    Pool.parse_pool(xml, path_of_pool, type_of_pool)
  end

  def initialize(pkm_xml)
    @xml_doc = pkm_xml
    @ausgangskontext_pool = PKM.parse_pool(@xml_doc, :ausgangskontext_pool)
    @ausgangsschnittstellen_pool = PKM.parse_pool(@xml_doc, :ausgangsschnittstellen_pool)
  end

  attr_reader :ausgangskontext_pool, :ausgangsschnittstellen_pool, :xml_doc

  def cr374?
    return false if @ausgangsschnittstellen_pool.nil? || @ausgangsschnittstellen_pool.empty?

    @ausgangsschnittstellen_pool.cr374?
  end
end
