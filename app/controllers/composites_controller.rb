class CompositesController < ApplicationController
  def allgroups
    render :json => ConditionGroup.all.collect {|g| g.name}
  end
end
