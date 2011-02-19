class VocabularyController < ApplicationController
  def units
    render :json => VocabularyEntry.find_all_by_vocab_type("unit").collect {|entry| entry.key}
  end

  def metadata_types
    render :json => Species.find_by_name('Halobacterium sp. NRC-1').vocabulary_entries.collect {|entry| entry.key}
  end
end
