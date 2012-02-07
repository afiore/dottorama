require 'rubygems'
require 'bundler'
require 'rack/coffee'

Bundler.require

if ENV['RACK_ENV'].to_sym == :development

  puts "[development]: compiling coffeescript"

  require 'coffee-script'

  use Rack::Coffee, {
    :root => File.dirname(__FILE__) + "/static",
    :urls => '/js'
  }
end

require './miurviz.rb'
run Miurviz
