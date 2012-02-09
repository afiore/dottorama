require "sinatra"
require "sinatra/reloader"
require "pry"
require "json"
require "../lib/miur.rb"

class Miurviz < Sinatra::Base

  configure :development do
    register Sinatra::Reloader
    also_reload "../lib/miur.rb"
    also_reload "../lib/miur/statistiche.rb"
  end

  set :public_folder, File.dirname(__FILE__) + '/static'

  get "/" do
    erb :index
  end


  get "/miur_aree.js" do
    content_type "text/javascript"
    erb :aree, :layout => false, :locals => {:aree => Miur::AREE }
  end

  get "/distributions/:ciclo" do
    ciclo = params[:ciclo] || 19

    content_type "application/json"
    Miur::Statistiche::distribuzioni_per_gruppo_e_per_settore(ciclo, d3format=true).to_json
  end


  get "/distributions/:attribute/:ciclo" do
    attribute = params[:attribute] || "area"
    ciclo = params[:ciclo] || 19

    content_type "application/json"
    Miur::Statistiche::distribuzioni_per_ciclo(attribute, ciclo).to_json
  end

  get "/co_occurrencies/:attribute/:value/:ciclo" do
    attribute = params[:attribute]
    value = params[:value]
    cycle = params[:ciclo] || 19

    content_type "application/json"
    Miur::Statistiche::co_occurrencies(attribute, value, cycle).to_json
  end
end
