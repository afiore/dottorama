require 'pp'
module Miur
  module Statistiche
    class << self

      def co_occurrencies(attribute, value, ciclo=19)
        Dottorato.find(attribute.to_sym => Array(value), :ciclo => ciclo).map(&:settore.to_sym).flatten. #get all the sectors
          reject { |settore| settore ==  value }.
          reduce({}) { |memo, settore| memo.merge(settore => memo.fetch(settore, 0) + 1 ) }. # count co-occurencies for each sector
          sort { |a, b| b[1] <=> a[1] }
      end

      def distribuzioni_per_ciclo(attributo, ciclo=19)
        klass = Kernel.const_get(attributo.to_s.capitalize)
        klass.all.map(&:nome).each_with_object({}) do |value, stats|
          stats[value] = Dottorato.find(attributo.to_sym => [value], :ciclo => ciclo).size

        end.sort { |a, b| b[1] <=> a[1] }
      end

      def distribuzioni_per_gruppo_e_per_settore(ciclo=19, want_d3format=false)
        stats = distribuzioni_per_ciclo(:settore, ciclo).group_by { |(settore, conto)| settore.split('/').first.strip   }
        stats = stats.each_with_object({}) do |(area_id, counts), newstats|
          area, _ = *Miur::AREE.detect { |num, data| Array(data[:id]).include?(area_id) }
          puts "CANNOT FIND #{area_id}"
          newstats[area] && newstats[area].concat(counts) || newstats[area] = counts
        end
        want_d3format ? d3format(stats) : stats
      end

      def d3format(data)
        root = {:name => "root", :children => data.map { |settore, sottosettori| {:name => settore, :children => [], :human_name => AREE[settore] && AREE[settore][:name], :total =>  sottosettori.map { |name, count| count }.reduce(&:+) } } }

        root[:children].each do |node|
          area = node[:name]

          # we create a graph node for each 20 PhD grants (otherwise the whole thing will take ages to load)
          node[:children] = data[node[:name]].map do |(name, count)|
            settore_hash = Miur::AREE[area][:settori].detect { |s| s[:id] == name } unless area.nil?
            {:name => name, :children => Range.new(1, count/10).to_a.map {{}}, :total => count, :human_name => settore_hash && settore_hash[:name] }
          end
        end
      end

    end
  end
end
