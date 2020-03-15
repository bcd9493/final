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
users_table = DB.from(:users)
GOOGLE_MAPS_API_KEY = AIzaSyCtovsQvkIUWlNqtYwXY87gEd4ZSmJEhMw 

# put your API credentials here (found on your Twilio dashboard)
account_sid = ENV["ACCOUNT_ID"]
auth_token = ENV["TOKEN"]

# set up a client to talk to the Twilio REST API
client = Twilio::REST::Client.new(account_sid, auth_token)

before do
    @current_user = users_table.where(id: session["user_id"]).to_a[0]
end

get "/" do
    puts shops_table.all
    @shops = shops_table.all
    view "shops"
end

get "/shops/:id" do
    @shop = shops_table.where(id: params[:id]).to_a[0]
    @ranking = rankings_table.where(event_id: @shop[:id])
    @helpful_count = rankings_table.where(event_id: @shop[:id], helpful: true).count
    @nothelpful_count = rankings_table.where(event_id: @shop[:id], helpful: false).count
    @friendly_count = rankings_table.where(event_id: @shop[:id], friendly: true).count
    @notfriendly_count = rankings_table.where(event_id: @shop[:id], friendly: false).count
    @time_count = rankings_table.where(event_id: @shop[:id], time: true).count
    @nottime_count = rankings_table.where(event_id: @shop[:id], time: false).count
    @users_table = users_table
    view "shop"
end

get "/shops/:id/rankings/new" do
    @shop = shops_table.where(id: params[:id]).to_a[0]
    view "shop_rank"
end

get "/shops/:id/rankings/ranked" do
    puts params
    @shop = shops_table.where(id: params[:id]).to_a[0]
    rankings_table.insert(event_id: params["id"],
                       user_id: session["user_id"],
                       helpful: params["helpful"],
                       friendly: params["friendly"],
                       time: params["time"])
    view "ranked"
end

get "/users/new" do
    view "newuser"
end

post "/users/create" do
    puts params
    hashed_password = BCrypt::Password.create(params["password"])
    users_table.insert(name: params["name"], email: params["email"], password: hashed_password)
    # send the SMS from your trial Twilio number to your verified non-Twilio number
    client.messages.create(
    from: "+13012652048", 
    to: "+14192025642",
    body: "Another user, Brad we're crushing it!")
    view "createuser"
end

get "/logins/new" do
    view "newlogin"
end

post "/logins/create" do
    user = users_table.where(email: params["email"]).to_a[0]
    if user && BCrypt::Password::new(user[:password]) == params["password"]
        session["user_id"] = user[:id]
        @current_user = user
        view "createlogin"
    else
        view "loginfailed"
    end
end

get "/logout" do
    session["user_id"] = nil
    @current_user = nil
    view "logout"
end
