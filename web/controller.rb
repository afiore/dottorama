require "../lib/miur.rb"

ignore /Cakefile/, /src/, "Guardfile"
priority "index.html.erb" => 2, /data/ => 1

helpers do
  def build_data
    @distributions, @distribution_averages, @co_occurrencies, @averages = *Miur::build_datasets

    File.open("data/distributions.json","w") { |file| file.write(@distributions.to_json) }

    @co_occurrencies.each do |(sector, data)|
      sector = sector.gsub /\//, '-'
      File.open("data/#{sector}_co-occurrencies.json", "w") { |file| file.write(data.to_json) }
    end

    File.open("data/_average_distributions.json", "w")  { |file| file.write(@distribution_averages.to_json) }
    File.open("data/_average_co-occurencies.json", "w") { |file| file.write(@averages.to_json) }
  end
end

if Dir["data/*.json"].empty?
  before "index.html.erb" do
    build_data
  end
end

## force copying data directory if stasis does not do it
`cp -r data public` unless Dir["public/data"].any?
