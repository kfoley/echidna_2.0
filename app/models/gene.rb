class Gene < ActiveRecord::Base
  def any_synonym
    a = send(:alias)
    return gene_name if a.nil? and !gene_name.nil?
    return a if gene_name.nil? and !a.nil?
    return a if !gene_name.nil? and !a.nil? # watch out for VNG1637G -> a  = ura3, g = pyrF
    nil
  end
end
