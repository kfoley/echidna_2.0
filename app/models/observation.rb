class Observation < ActiveRecord::Base
  belongs_to :condition
  belongs_to :controlled_vocab_item, :foreign_key => "name_id"
  belongs_to :unit

  def name
    ControlledVocabItem.find(name_id).name
  end  
end
