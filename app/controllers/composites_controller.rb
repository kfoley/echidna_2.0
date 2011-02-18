class CompositesController < ApplicationController
  def allgroups
    #render :layout => false
    render :json => ConditionGroup.all.collect {|g| g.name}
  end
end
