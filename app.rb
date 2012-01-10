# -*- coding: utf-8 -*-

require 'sinatra'
require 'digest/sha1'
require 'RMagick'
require 'mongoid'
require './models/image'

Mongoid.configure do |config|
    config.master = Mongo::Connection.new.db("pic_toqoz_net")
end

configure do
  set :image_dir, 'public'
  set :thumb_dir, 'thumb'
  set :thumb_size, 140
  set :host, 'pic.toqoz.net'
  set :logging, false
end

get '/' do
  @images = Dir[options.image_dir + '/**.\png'].map {|i|
    File.basename(i)
  }

  erb :index
end

post '/upload.cgi' do
  set_image(params['imagedata'][:tempfile].read)
end

get '/stylesheets/:name.css' do
  sass :"stylesheets/#{params[:name]}"
end

def set_image(data)
  name = Digest::SHA1.hexdigest(data.to_s)
  path = "#{options.image_dir}/#{name}.png"
  image = Magick::Image.from_blob(data).last
  # set /public/xxx.png
  image.write("#{options.image_dir}/#{name}.png")

  # set /public/thumb/xxx.png
  image.resize_to_fit!(options.thumb_size, options.thumb_size)
  image.write("#{options.image_dir}/thumb/#{name}.png")

  # save in mongodb
  Image.create(name: "#{name}")
  "#{options.host}/#{name}.png"
end
