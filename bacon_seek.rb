require 'rubygems' if RUBY_VERSION < "1.9"
require 'sinatra'
require 'json'
require 'koala'

class BaconSeek < Sinatra::Base
  set :static, true
  set :public, 'public'
  set :views,  'views'
  set :show_exceptions, true

  get '/' do
    erb :index
  end

  get '/search' do
    erb :index
  end

  post '/search' do
    begin
      @graph = Koala::Facebook::API.new
      @results = nil
      if params[:query] =~ /\[/ #contains Object type filter
        object_type, *search_query = params[:query].split(/\]/)
        @results = @graph.search(search_query, {:type => "#{object_type[1..-1]}"})
      else
        @results = @graph.search(params[:query])
      end
      @results.each_with_index do |item, index|
        @results[index]["likes"] = @graph.get_object(item["id"])["likes"] #adding likes to hash
      end
      erb :search
    rescue => error
      erb :n00b
    end
  end

  get '/n00b' do
    erb :n00b
  end
end
