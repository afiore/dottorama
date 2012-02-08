module Miur
  module Statistiche
    class << self

      def distribuzioni_per_ciclo(attributo, ciclo=19)
        klass = Kernel.const_get(attributo.to_s.capitalize)
        klass.all.map(&:nome).each_with_object({}) do |value, stats|
          stats[value] = Dottorato.find(attributo.to_sym => [value], :ciclo => ciclo).size

        end.sort { |a, b| b[1] <=> a[1] }
      end

      def distribuzioni_per_gruppo_e_per_settore(ciclo=19, want_d3format=false)
        stats = distribuzioni_per_ciclo(:settore, ciclo).group_by { |(settore, conto)| settore.split('/').first.strip   }
        want_d3format ? d3format(stats) : stats
      end

      def d3format(data)
        root = {:name => "root", :children => data.map { |settore, sottosettori| {:name => settore, :children => [], :total =>  sottosettori.map { |name, count| count }.reduce(&:+) } } }
        root[:children].each do |node|
          node[:children] = data[node[:name]].map { |(name, count)| {:name => name, :children => Range.new(1, count/20).to_a.map {{}}, :total => count }}
        end
      end

    end
  end
end
