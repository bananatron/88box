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
  erb :about 
end

#About
get '/contact' do #can change to ID if we want to
  erb :contact 
end


#Route by date
get 'case/:case/:date' do #can change to ID if we want to
  c = params[:case]
  d = params[:date]
  @fb = 'https://testchart.firebaseio.com/' + c + "/" + d
  erb :index
end


# Post route for sending post data which will write to firebase after formatting
# This may not even need to be used if the ruby tests write directly to firebase

post '/save/:test_case/:date/:response_time/:status' do
  
  test_case = params[:test_case]
  date = params[:date]
  response_time = params[:response_time]
  status = params[:status]
  time = Time.now.hour.to_s + "_" + Time.now.min.to_s + "_" + Time.now.sec.to_s
  
  h = Hash.new
  h["response_time"] = response_time
  h["status"] = status
  h["time"] = time
  
  firebase = Firebase::Client.new($base_uri+"/"+test_case+"/"+date)
  response = firebase.set(data["time"], h)

  #return response.status.to_s
  return response.success?
end



#GET for testing (CURRENTLY BROKEN)
get '/savetest' do 
  postData = Net::HTTP.post_form(URI.parse('http://scrb-211217.usw1-2.nitrousbox.com/save/case2/05-04-09/'), {'postKey'=>'postValue'})
  puts postData.body
end




#GET for TESTING
#sets random repsonse time
get '/save/:case_id/:status/:message' do
  
  case_id = params[:case_id] # test case ID
  time = params[:time] # date of test case
  response_time = params[:response_time] # response time of testcase
  status = params[:status] # test status (0 or 1)
  message = params[:message] if message != "" # message on entry
  time = (Time.now.to_f * 1000).to_i.to_s
  
  #creating object to write to firebase
  h = Hash.new
  h["response_time"] = rand(10000).to_s #first 6 characters of random response time
  h["status"] = status.to_i
  h["message"] = message.gsub("__", " ") if message #receives message where __ is replaced with spaces
  
  firebase = Firebase::Client.new($base_uri+"/"+case_id + "/" + time )
  response = firebase.set(h["time"], h)

  redirect_to redirect '/'
  
end



