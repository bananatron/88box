require 'net/http'
require 'json'
#require_relative 'super_sekrets' #Store CONS_KEY & USER_NAME Comment out for heroku


class Photo #Will store only useful information we want from 500px
  attr_reader :thumb, :id, :rating, :name
  
  def initialize(thumbnail_url, id, rating, name)  
    @thumb = thumbnail_url
    @id = id
    @rating = rating
    @name = name
  end  
   
  def to_s  
    puts "{thumb: #{@thumb}, id: #{@id}, rating #{@rating}}"
  end  
end  #end Photo


############
# Helpers #
##########

def get_page(page_num) #RETURN page from json string as HASH
  raise abort("No username supplied. Aborting") if USER_NAME == "" #Raise for empty
  raise abort("No key supplied. Aborting") if CONS_KEY == ""
  url = "https://api.500px.com/v1/photos?feature=user&username=#{USER_NAME}&page=#{page_num}&consumer_key=#{CONS_KEY}"
  rr = Net::HTTP.get(URI.parse(url))
  JSON.parse(rr)
end


def get_photos(page_hash) #RETURN ARRAY of photos on page as PHOTO
  aa = []
  page = page_hash
  
  page["photos"].each do |p|
    image_url = p["image_url"]
    id = p["id"]
    rating = p["rating"]
    name = p["name"]
    
    aa << Photo.new(image_url, id, rating, name)
  end
  
  return aa
end




