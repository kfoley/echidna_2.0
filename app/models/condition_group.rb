class ConditionGroup < ActiveRecord::Base
  has_many :condition_groupings, :dependent => :destroy
  has_many :conditions, :through => :condition_groupings
  accepts_nested_attributes_for :conditions  
end
