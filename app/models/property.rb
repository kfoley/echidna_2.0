class Property < ActiveRecord::Base
  has_many :composites_properties
  has_many :composites, :through => :composites_properties
end
