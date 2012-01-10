# -*- coding: utf-8 -*-

require 'sinatra'
require 'digest/sha1'
#gem "rmagick", :require => "RMagick"
require 'RMagick'

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

def set_image(data)
  name = Digest::SHA1.hexdigest(data.to_s)
  path = "#{options.image_dir}/#{name}.png"
  # set /public/xxx.png
  File.open("#{path}", 'w').print(data)

  # set /public/thumb/xxx.png
  image = Magick::Image.from_blob(data).last
  image.resize_to_fit!(options.thumb_size, options.thumb_size)
  image.write("#{options.image_dir}/thumb/#{name}.png")

  "#{options.host}/#{name}.png"
end
