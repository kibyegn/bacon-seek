require 'rubygems' if RUBY_VERSION < "1.9"
require 'sinatra'
require 'json'
require 'koala'

class BaconSeek < Sinatra::Base
  set :show_exceptions, true
  set :logging, true
  set :dump_errors, true
  set :raise_errors, true

  get '/' do
    show "index"
  end

  get '/search' do
    show "index"
  end

  post '/search' do
    graph unless @graph
    @results = nil
    if params[:query] =~ /\[/ #contains Object type filter
      object_type, *search_query = params[:query].split(/\]/)
      @results = @graph.search(search_query, {:type => "#{object_type[1..-1]}"})
    else
      @results = @graph.search(params[:query])
    end
    @results.each_with_index do |item, index|
      @results[index]["likes"] = @graph.get_object(item["id"])["likes"]
    end
    show "search"
  end

  get "/spy/:id" do
    graph unless @graph
    @fb_object = @graph.get_object(params[:id])
    show "spy"
  end

  def graph
    @graph = Koala::Facebook::API.new
  end

  def show(page, layout = true)
    begin
      erb page.to_sym, {:layout => layout}
    rescue
      erb :error, {:layout => false}, :error => "You broke it!"
    end
  end
end
