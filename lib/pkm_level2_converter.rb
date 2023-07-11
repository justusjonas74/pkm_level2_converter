# frozen_string_literal: true

require_relative 'pkm_level2_converter/version'
require_relative 'pkm_level2_converter/pkm'
require_relative 'pkm_level2_converter/pkm_xml'

module PkmLevel2Converter
  class Error < StandardError; end
  PKM = ::PKM
  PKMXml = ::PKMXml
end
