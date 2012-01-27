module Miur
  CSV_URL = "http://cercauniversita.cineca.it/php5/dottorati/vis_dottorati.php?universita=991&settore=0000&area={area}&radiogroup=E&titolo=&ciclo=0000&testuale=1&nomefile=RICERCADOTTORATI&pagina=A"
  AREE = 1..14
  class DottoratiScraper
    def run
      (AREE).each do |area|
        url = CSV_URL.gsub(/{area}/, "%02d" % area)
        doc = Nokogiri::HTML(open(url).read)
        rows = doc.css("tr"); rows.shift

        puts "#{area} di 14, #{rows.size} record scaricati"
        rows.each_with_index do |row, i|

          dottorato = Dottorato.new
          row.css("td").each_with_index do |cell, index|
            setter = "#{dottorato.attributes[index]}="
            dottorato.send(setter, cell.text)
          end
          dottorato.save
        end
      end
    end
  end
end

# query: list tutti i settori che co-occorrono con un dato settore
#
#  Dottorato.find(:settore => ['BIO/09']).map(&:settore).flatten.reject { |t| t ==  "BIO/09" }.reduce({}) { |memo, t| memo.merge(t => memo.fetch(t, 0) + 1 ) }.sort { |a, b| b[1] <=> a[1] }
#

