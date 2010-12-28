class ConditionGrouping < ActiveRecord::Base
  belongs_to :condition
  belongs_to :condition_group
end
