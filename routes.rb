
#    /$$$$$$   /$$$$$$  /$$                          
#   /$$__  $$ /$$__  $$| $$                          
#  | $$  \ $$| $$  \ $$| $$$$$$$   /$$$$$$  /$$   /$$
#  |  $$$$$$/|  $$$$$$/| $$__  $$ /$$__  $$|  $$ /$$/
#   >$$__  $$ >$$__  $$| $$  \ $$| $$  \ $$ \  $$$$/ 
#  | $$  \ $$| $$  \ $$| $$  | $$| $$  | $$  >$$  $$ 
#  |  $$$$$$/|  $$$$$$/| $$$$$$$/|  $$$$$$/ /$$/\  $$
#   \______/  \______/ |_______/  \______/ |__/  \__/
                                                  

require 'sinatra'
require 'net/http'
require 'json'
require_relative 'px'


configure :development do
  set :server, 'webrick'
  set :bind, '0.0.0.0'
  set :port, 3000
end


#Root
get '/' do
  $username = "88box"
  @user = $username
  @master_photolist = [] #Array to contain all PHOTO objects which will be passed to the front

  page_first = get_page(1) #Get first page
  page_total = page_first["total_pages"].to_i #Get page count

  get_photos(page_first).each { |ph| @master_photolist << ph } #Get photos from first page

  if page_total > 1 #Get photos from remaining pages
    until page_total <= 1 do 
     pp = get_page(page_total)
     get_photos(pp).each { |ph| @master_photolist << ph }

     page_total -= 1
    end
  end

  puts "Found #{@master_photolist.count} photos."
  erb :index # Load index.erb

end


#About
get '/about' do #can change to ID if we want to
  @user = "88box"
  erb :about 
end

#About
get '/contact' do #can change to ID if we want to
  @user = "88box"
  erb :contact 
end



#Other 500px users
get '/o/:user' do
  $username = params[:user]
  @user = $username
  @master_photolist = [] #Array to contain all PHOTO objects which will be passed to the front

  page_first = get_page(1) #Get first page
  page_total = page_first["total_pages"].to_i #Get page count

  get_photos(page_first).each { |ph| @master_photolist << ph } #Get photos from first page

  if page_total > 1 #Get photos from remaining pages
    until page_total <= 1 do 
     pp = get_page(page_total)
     get_photos(pp).each { |ph| @master_photolist << ph }

     page_total -= 1
    end
  end

  puts "Found #{@master_photolist.count} photos."
  
  erb :index
end

