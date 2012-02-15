require "../lib/miur.rb"

ignore /Gemfile/, /assets\/coffee/, "Guardfile"

before "index.html.erb" do
  next unless Dir["data/*.json"].empty?

  @distributions, @co_occurrencies = *Miur::build_datasets

  File.open("data/distributions.json","w") { |file| file.write(@distributions.to_json) }

  @co_occurrencies.each do |(sector, data)|
    sector = sector.gsub /\//, '-'
    File.open("data/#{sector}_co-occurrencies.json", "w") { |file| file.write(data.to_json) }
  end
end