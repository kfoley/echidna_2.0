class Condition < ActiveRecord::Base
  #belongs_to :species
  has_many :observations, :dependent => :destroy
  has_many :condition_groups, :through => :condition_groupings 
  #belongs_to :reference_sample
  #belongs_to :growth_media_recipe
  
  #belongs_to :importer, :class_name => "User"
  #belongs_to :owner, :class_name => "User"
  
  #attr_accessor :num_groups
  accepts_nested_attributes_for :observations, :reject_if => lambda { |a| a[:string_value].blank? }, :allow_destroy => true
end
