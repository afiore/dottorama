#
# Working name: dottorama.it
#
# information landscape della ricerca Italiana attraverso 
# l'analisi della distribuzione dei Dottorati di ricerca (dati da http://dottorati.miur.it)
#
#


$: << File.realpath(__FILE__.gsub(/\.rb$/, ''))

require "ohm"
require "ohm/contrib"
require "nokogiri"
require "open-uri"
require "models"
require "scraper"
require "statistiche"
require "pry"


module Miur
end
