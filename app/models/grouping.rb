class Grouping < ActiveRecord::Base
  belongs_to :condition_group, :foreign_key => "parent_id"
  belongs_to :condition, :foreign_key => "child_id"
end
