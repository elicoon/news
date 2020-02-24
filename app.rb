require "sinatra"
require "sinatra/reloader"
require "geocoder"
require "forecast_io"
require "httparty"
require "open-uri"
def view(template); erb template.to_sym; end
before { puts "Parameters: #{params}" }                                     

# enter your Dark Sky API key here
ForecastIO.api_key = "2d31f2693209b31c67232a10ff2a1feb"

# NewsAPI key and code is below
url = "https://newsapi.org/v2/top-headlines?country=us&apiKey=be45392a87674b5a9b2f298fb7074f50"
news = HTTParty.get(url).parsed_response.to_hash

get "/" do
  # show a view that asks for the location
  view "ask"
end

get "/news" do
  # do everything else:
  # start with obtaining a location and turning it into array "lat_long" where the first
  # number is the lat and the second number is the long
@form_entry = params["q"]
location_search = Geocoder.search(@form_entry)
lat_long = location_search.first.coordinates # => [lat, long]
@location_result_city=location_search.first.city
"#{lat_long[0]} #{lat_long[1]}"

# next, pass that location to darksky to obtain weather information in array "forecast"
forecast = ForecastIO.forecast(lat_long[0],lat_long[1]).to_hash

# define current forecast variables within the hash
@current_temperature=forecast["currently"]["temperature"]
@current_conditions=forecast["currently"]["summary"]
@future_forecast=forecast["daily"]["data"] #note that this needs a loop to actually define which day we want, plus ["temperature"] or ["summary"] or ["time"]

# dealing with time in forecast hash. Can use these variables for loops
@today_day_of_week=Time.at(forecast["currently"]["time"]).strftime("%A")
# @referenced_day_of_week=Time.at(forecast["daily"]["data"]["SPECIFY DAY LOOPS"]["time"]]).strftime("%A") 


view "news"
end