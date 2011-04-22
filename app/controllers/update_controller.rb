class UpdateController < ApplicationController

  include Blacklight::SolrHelper
  include EchidnaImport
  
  def index
    # @doc_ids = session[:folder_document_ids]
    #puts "=========================="
    #puts @doc_ids.to_json
    # @response, @documents = get_solr_response_for_field_values("id",session[:folder_document_ids] || [])    
    #puts "=========================="
    # @doc_ids
    #get_condition_metadata
  end

  def folder_contents
    @doc_ids = session[:folder_document_ids]
    get_condition_metadata(@doc_ids)

  end

  def get_condition_metadata(contents)
    #result = {}
    result = []

    contents.each { |g_id|
      #result ||= {}
      mdata = {}
      puts g_id

      mdata['group_id'] = g_id
      mdata['children'] = []

      child_ids = Composite.find_by_sql ["SELECT id FROM composites WHERE id IN (SELECT child_id FROM groupings WHERE parent_id=?)", g_id]

      child = {}
      cond_attr = []
      child_ids.collect { |child|
        child.id
        c_id = child.id.to_s
        puts child.id

        #result[g_id][c_id] ||= []
        #result['group_id']['child_id'] ||= []
        #result['group_id']['child_id'] = c_id

        child['child_id'] = c_id
        #mdata['children'] << attributes['child_id']

        metadata = Composite.find_by_sql ["SELECT p.key, p.value, cp.id, cp.composite_id FROM composites c INNER JOIN composites_properties cp ON cp.composite_id=c.id INNER JOIN properties p ON p.id=cp.property_id WHERE c.id=?", child.id] 

        #mdata['attr'] = []

        metadata.collect { | comp |
          #result[g_id][c_id] << comp.attributes 
          puts comp.attributes
          cond_attr << comp.attributes 
        }

        child['mdata'] = cond_attr
        #mdata['children'] << attributes['mdata']
        mdata['children'] << child
        cond_attr = []
      }


      result << mdata
      puts "------------------------------------------"
      puts result.to_json
      puts "------------------------------------------"
      #result << mdata
    }

    render :json => result
  end

end
