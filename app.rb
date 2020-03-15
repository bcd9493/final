# Set up for the application and database. DO NOT CHANGE. #############################
require "sinatra"                                                                     #
require "sinatra/reloader" if development?                                            #
require "sequel"                                                                      #
require "logger"                                                                      #
require "twilio-ruby"                                                                 #
require "bcrypt"                                                                      #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB ||= Sequel.connect(connection_string)                                              #
DB.loggers << Logger.new($stdout) unless DB.loggers.size > 0                          #
def view(template); erb template.to_sym; end                                          #
use Rack::Session::Cookie, key: 'rack.session', path: '/', secret: 'secret'           #
before { puts; puts "--------------- NEW REQUEST ---------------"; puts }             #
after { puts; }                                                                       #
#######################################################################################

shops_table = DB.from(:shops)
rankings_table = DB.from(:rankings)

get "/" do
    puts shops_table.all
    @shops = shops_table.all
    view "shops"
end

get "/shops/:id" do
    @shop = shops_table.where(id: params[:id]).first
    view "shop"
end

get "/shops/:id/rankings/new" do
    @shop = shops_table.where(id: params[:id]).first
    view "shop_rank"
end

get "/shops/:id/rankings/ranked" do
    puts params
    @shop = shops_table.where(id: params["id"])
    rankings_table.insert(event_id: params["id"],
                       user_id: session["user_id"],
                       going: params["going"],
                       comments: params["comments"])
    view "ranked"
end
