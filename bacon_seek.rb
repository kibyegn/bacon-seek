require 'rubygems' if RUBY_VERSION < "1.9"
require 'sinatra'
require 'json'
require 'koala'

class BaconSeek < Sinatra::Base
  set :show_exceptions, true
  set :logging, true
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
    item = @graph.get_object(params[:id])
    @links = get_links(item)
    @item = strip_redundants(item)
    show "spy"
  end

  def graph
    @graph = Koala::Facebook::API.new
  end

  def show(page, layout = true)
    begin
      erb page.to_sym, {:layout => layout}
    rescue => error
      erb :error, {:layout => false}, :error => error.inspect
    end
  end

  def strip_redundants(item)
    item.reject! {|k, v| %w"id name link website cover is_published".include? k }
    item.keys.each do |key|
      new_key = key.gsub(/^([a-z])/) { $1.capitalize }
      new_key = key.gsub('_', ' ')
      item[new_key] = item[key]
      item.delete(key)
    end

    item
  end

  def get_links(item)
    links = {}
    links["name"] = item["name"] if item.has_key?("name")
    links["fb_page"] = item["link"] if item.has_key?("link")
    links["website"] = item["link"] if item.has_key?("website")
    links["avatar"] = item["cover"]["source"] if item.has_key?("cover")

    links
  end
end
