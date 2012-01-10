# -*- coding: utf-8 -*-

class Image
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
end
