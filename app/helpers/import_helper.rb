module ImportHelper

  def link_to_remove_fields(text, f)
    f.hidden_field(:_destroy) + link_to_function(text, "removeFields(this)", :title => "Remove Observation")
  end

  def link_to_add_fields(text, cond, association, vocab_items, units)
    new_object = cond.object.class.reflect_on_association(association).klass.new
    fields = cond.fields_for(association, new_object,
                             :child_index => "new_#{association}") do |obs|
      render(association.to_s.singularize + "_edit",
             :obs => obs, :vocab_items => vocab_items, :units => units)
    end
    link_to_function(text, h("addFields(this, \"#{association}\", \"#{escape_javascript(fields)}\")"), :title => "Add Observation")
  end
end

