# Set up for the application and database. DO NOT CHANGE. #############################
require "sequel"                                                                      #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB = Sequel.connect(connection_string)                                                #
#######################################################################################

# Database schema - this should reflect your domain model
DB.create_table! :shops do
  primary_key :id
  String :title
  String :description, text: true
end
DB.create_table! :rankings do
  primary_key :id
  foreign_key :event_id
  foreign_key :user_id
  Boolean :helpful
  Boolean :friendly
  Boolean :time
end
DB.create_table! :users do
  primary_key :id
  String :name
  String :email
  String :password
end


# Insert initial (seed) data
shops_table = DB.from(:shops)

shops_table.insert(title: "Dispensary 33", 
                    description: "Medical and Recreational Weed Dispensary")

shops_table.insert(title: "Sunnyside Dispensary - Lakeview", 
                    description: "Medical and Recreational Weed Dispensary")

shops_table.insert(title: "GreenGate Chicago", 
                    description: "Medical and Recreational Weed Dispensary")

shops_table.insert(title: "MedMen Chicago - Evanston (Maple Ave.)", 
                    description: "Medical and Recreational Weed Dispensary")

