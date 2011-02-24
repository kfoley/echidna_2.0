class CompositesProperties < ActiveRecord::Base
  belongs_to :composite
  belongs_to :property
end
