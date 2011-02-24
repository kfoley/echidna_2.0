class Composite < ActiveRecord::Base
  has_many :composites_properties
  has_many :properties, :through => :composites_properties
end
