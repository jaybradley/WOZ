require 'rubygems'
require 'sinatra'

Sinatra::Application.default_options.merge!(
  :run => false,
  :enf => :production
)

require 'photopalwoz.rb'
run Sinatra::Application
