# frozen_string_literal: true
require 'nokogiri'
require 'pry'
require 'pathname'
require_relative "pkm_level2_converter/version"
require_relative "pkm_level2_converter/pkm"

module PkmLevel2Converter
  class Error < StandardError; end
  PKM = ::PKM
  
end
