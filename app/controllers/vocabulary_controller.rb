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
    @species = VocabularyEntry.find_by_sql("SELECT properties.value FROM properties, vocabulary_entries WHERE vocabulary_entries.vocab_type='species' AND vocabulary_entries.`key`=properties.`key`").collect {|term| term.value}    
    #"SELECT `key` FROM vocabulary_entries WHERE vocab_type IN (select `key` from vocabulary_entries where vocab_type='species')").collect {|term| term.key}    
    puts "TESTING .... #{@species}"

    @data_type = VocabularyEntry.find_by_sql("SELECT DISTINCT properties.value FROM properties, vocabulary_entries WHERE vocabulary_entries.vocab_type='measurement' AND vocabulary_entries.`key`=properties.`key`").collect {|term| term.value}

    @technology = VocabularyEntry.find_all_by_vocab_type("technology").collect {|term| term.key}    
    
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

  def add_new_global_terms
    globalTerm = params[:gTerm]
    globalType = params[:gType]
    # techTerm is the vocab_type
    techTerm = params[:techTerm]
    techDescr = params[:techDescr]

    if (globalTerm != '')
      if (globalType == 'species') 
        # add new property
        success1 = add_new_property(globalType,globalTerm)
      elsif (globalType == 'measurement')
        # add new property, change Type to 'data type'
        globalType = 'data type'
        success1 = add_new_property(globalType,globalTerm)
      else
        # add new technology vocab entry
        success1 = add_new_entry(globalTerm,globalType)
      end
    else
      success1 = 'true'
    end

    if (techDescr != '')
      success2 = add_new_entry(techDescr, techTerm)
    else
      success2 = 'true'
    end

    if (success1 == 'false' || success2 == 'false')
      render :json => ['false']
      #return false
    else
      render :json => ['true']      
      #return true
    end

  end

  def add_new_property(keyK, valueV)
    entry = Property.new(:key => keyK, :value => valueV)
    success = entry.save

    if success
      return true
    else
      return false
    end
  end

  def add_new_entry(keyK, valueV)
    entry = VocabularyEntry.new(:key => keyK, :vocab_type => valueV)
    success = entry.save

    if success
      return true
    else
      return false
    end

  end

end
