module Miur
  module Statistiche
    CICLI = 19..26

    class << self
      def co_occurrencies(attribute, value, cicles=CICLI.to_a)
        stats = {}
        stats[value] = Hash[Array(cicles).map do |ciclo|
          data = Hash[Dottorato.find(attribute => value, :ciclo => ciclo).map(&:settore.to_sym).flatten. #get all the sectors
            reject { |settore| attribute ==  value }.
            reduce({}) { |memo, settore| memo.merge(settore => memo.fetch(settore, 0) + 1 ) }. # count co-occurencies for each sector
            sort { |a, b| b[1] <=> a[1] }]

          [ciclo, data]
        end]
      end

      def co_occurrencies_averages(co_occurrencies)
        Hash[CICLI.to_a.map do |cycle|
          [cycle, co_occurrencies.values.map { |hash| hash[cycle].values }.flatten.reject(&:nil?).average]
        end]
      end

      def sector_distributions
        # looks up area code by sector name
        lookup_area = proc { |(nome_settore, distribuzioni)|
          area_id, _ = *AREE.detect { |area_id, data| data[:settori].detect { |settore| settore[:id] == nome_settore }}
          area_id
        }
        stats = Settore.all.map(&:nome).each_with_object({}) do |settore, stats|
          stats[settore] = Hash[CICLI.map { |ciclo| [ciclo.to_s, Dottorato.find(:ciclo => ciclo, :settore => settore).size ]}]
        end

        Hash[stats.group_by(&lookup_area).map { |k, v| [k, Hash[v]] }]
      end

      def max_per_cycle(distributions)
        frequencies = []

        distributions.each do |area, sectors|
          sectors.each do |sector_name, freqs| 
            freqs.each { |freq|  frequencies << freq }
          end
        end

        max_per_cycle = Array(CICLI).map do |ciclo| 
          [ciclo, frequencies.select {|cycle, *freq| ciclo.to_s == cycle.to_s }.map { | cycle, *freq | freq }.max ] 
        end

        Hash[max_per_cycle]
      end

    end
  end
end

class Array
  def average
    self.reduce(0.0) { |sum, n| sum + n } / self.size
  end
end
