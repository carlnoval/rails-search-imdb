# rails g controller movies
class MoviesController < ApplicationController
  def index
    @movies = Movie.all
  end
end
