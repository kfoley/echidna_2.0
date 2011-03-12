class VocabularyController < ApplicationController

  def units
    render :json => VocabularyEntry.find_all_by_vocab_type("unit").collect {|entry| entry.key}
  end

  def metadata_types
    render :json => Species.find_by_name('Halobacterium sp. NRC-1').vocabulary_entries.collect {|entry| entry.key}
  end

  def global_terms_test
    render :json => VocabularyEntry.find(:all, :conditions => ['vocab_type IN ("species","technology","measurement") ']).collect {|entry| entry.key}    
  end

  def global_terms
    @species = VocabularyEntry.find_by_sql("SELECT `key` FROM vocabulary_entries WHERE vocab_type IN (select `key` from vocabulary_entries where vocab_type='species')").collect {|term| term.key}    
    #puts "TESTING .... #{@species}"

    @data_type = VocabularyEntry.find_by_sql("SELECT DISTINCT properties.value FROM properties, vocabulary_entries WHERE vocabulary_entries.vocab_type='measurement' AND vocabulary_entries.`key`=properties.`key`").collect {|term| term.value}

    @technology = VocabularyEntry.find_all_by_vocab_type("technology").collect {|term| term.key}    
    
  end

  def species_terms

  end

  def data_type_terms

  end

  def technology_descr
    render :json => VocabularyEntry.find_by_sql("SELECT `key` FROM vocabulary_entries WHERE vocab_type IN (select `key` from vocabulary_entries where vocab_type='technology')").collect {|term| term.key}    
  end

  def global_terms_within_vocab
    result = VocabularyEntry.find_by_sql ["SELECT `key` FROM vocabulary_entries WHERE vocab_type IN (select `key` from vocabulary_entries where vocab_type=?)", params[:vocab_type]]

    render :json => result.collect {|term| term.key}
  end

  def global_terms_within_prop
    result = VocabularyEntry.find_by_sql ["SELECT DISTINCT properties.value FROM properties, vocabulary_entries WHERE vocabulary_entries.vocab_type=? AND vocabulary_entries.`key`=properties.`key`", params[:vocab_type]]

    render :json => result.collect {|term| term.value}  
  end

  def add_new_entry
    entry = VocabularyEntry.new(:key => params[:term], :vocab_type => params[:type])
    entry.save
  end

end
