class Condition < Composite
  has_many :groupings, :foreign_key => "child_id"
  has_many :condition_groups, :through => :groupings
  has_one :measurement_data 
end
