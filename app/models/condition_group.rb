class ConditionGroup < Composite
  has_many :groupings, :foreign_key => "parent_id"
  has_many :conditions, :through => :groupings
end
