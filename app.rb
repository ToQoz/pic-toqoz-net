# -*- coding: utf-8 -*-

require 'sinatra'
require 'digest/sha1'

set :image_dir, 'public'
set :logging, false

get '/' do
  @images = Dir[options.image_dir + '/**'].map {|i| File.basename(i)}

  erb :index
end

post '/upload.cgi' do
  data = params['imagedata'][:tempfile].read
  name = Digest::SHA1.hexdigest(data.to_s)
  File.open("#{options.image_dir}/#{name}.png", 'w').print(data)
  "http://#{request.host_with_port}/#{name}.png"
end
