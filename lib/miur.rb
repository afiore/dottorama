# encoding: UTF-8

# Working name: dottorama.it
#
# information landscape della ricerca Italiana attraverso 
# l'analisi della distribuzione dei Dottorati di ricerca (dati da http://dottorati.miur.it)
#
#

require "yaml"
require "json"
require "ohm"
require "ohm/contrib"
require "nokogiri"
require "escape_utils"
require "progressbar"
require "open-uri"

lib_path = File.realpath(__FILE__.gsub(/\.rb$/, ''))
$: << lib_path


module Miur
  class << self

    def build_datasets
      sectors = Settore.all.map(&:nome)
      areas   =  Area.all.map(&:nome)

      progress_bar = ProgressBar.new("sector-distributions", 2)
      sector_distributions = Statistiche::sector_distributions; progress_bar.inc
      sector_distributions = d3_format(sector_distributions.reject { |(k,v)| k.nil? }); progress_bar.inc && progress_bar.finish

      progress_bar = ProgressBar.new("sector-co-occurrencies", sectors.size + areas.size)

      data = sectors.each_with_object({}) do |sector, stats|
        stats[sector] = Statistiche::co_occurrencies(:settore, sector)
        progress_bar.inc
      end

      areadata = areas.each_with_object({}) do |area, stats|
        stats[area] = Statistiche::co_occurrencies(:area, area)
        progress_bar.inc
      end

      progress_bar.finish
      [sector_distributions, data.merge(areadata)]
    end

    def d3_format(data)
      data.map do |(area_id, sectors)|
        children = sectors.map do |(key, values)|
          {:name => key, :human_name => sector_name(area_id, key), :frequencies => values }
        end

        {:name => area_id, :human_name => area_name(area_id), :children => children }
      end
    end

    private
    def area_name(area_id)
      AREE[area_id] && AREE[area_id][:name].capitalize
    end

    def sector_name(area_id, sector_id)
      settore = AREE[area_id][:settori].detect { |sector| sector[:id] == sector_id }
      settore && settore[:name].capitalize
    end
  end
end

Miur.const_set(:AREE, YAML::load_file("#{lib_path}/aree.yml"))


require "models"
require "scraper"
require "statistiche"

