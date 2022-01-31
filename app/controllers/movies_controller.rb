# rails g controller movies
class MoviesController < ApplicationController
  def index
    if params[:query].present?

      # only returns movie title with case sensitive exact match
      # @movies = Movie.where(title: params[:query])

      # the `I` before `LIKE` takes care of exact case matching
      @movies = Movie.where("title ILIKE ?", params[:query])
    else
      @movies = Movie.order(title: :asc)
    end
  end
end
