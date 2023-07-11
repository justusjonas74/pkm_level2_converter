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

  def self.parse_pool(pool_symbol)
    pool = @@pools[pool_symbol]
    path_of_pool = pool[:path_of_pool]
    type_of_pool = pool[:type_of_pool]
    Pool.parse_pool(@xml_doc, path_of_pool, type_of_pool)
  end

  def initialize(pkm_xml)
    @xml_doc = pkm_xml
    @ausgangskontext_pool = PKM.parse_pool(:ausgangskontext_pool)
    @ausgangsschnittstellen_pool = PKM.parse_pool(:ausgangsschnittstellen_pool)
  end

  attr_reader :ausgangskontext_pool, :ausgangsschnittstellen_pool, :xml_doc

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

    # TODO: CR 374
  end

  def convert_ids_cr374
    ## Ist die Ausgangsschnittstelle 3 bzw. 4 im Kontrollmodul vorhanden?

    # dl-km | rn-tm / ausgangsschnittstelle-pool / item / nr = 3 | 4
    xpath = '//xmlns:rn-tm/xmlns:ausgangsschnittstelle-pool | //xmlns:dl-km/xmlns:ausgangsschnittstelle-pool'
    asst_pool_raw = @xml_doc.at_xpath(xpath)
    asst_pool = AusgangsschnittstellenPool.new(asst_pool_raw)

    if !asst_pool_raw || asst_pool.ausgangsschnittstellen.empty?
      puts 'Das RN-TM / DL-KM hat keinerlei Aussgangsschnittstellen definiert. '
      return nil
    end

    if asst_pool.cr374?
      puts 'CR374 ist umgesetzt. OrgIDs werden angepasst.'
    else
      puts 'Das RN-TM / DL-KM hat keinerlei Aussgangsschnittstellen nach CR 374 definiert.'
      nil
    end
  end
end
