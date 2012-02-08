# encoding: UTF-8

# Working name: dottorama.it
#
# information landscape della ricerca Italiana attraverso 
# l'analisi della distribuzione dei Dottorati di ricerca (dati da http://dottorati.miur.it)
#
#

require "yaml"
require "ohm"
require "ohm/contrib"
require "nokogiri"
require "open-uri"
require "pry"

lib_path = File.realpath(__FILE__.gsub(/\.rb$/, ''))
$: << lib_path

module Miur; end
Miur.const_set(:AREE, YAML::load_file("#{lib_path}/aree.yml"))


require "models"
require "scraper"
require "statistiche"


