# rails g controller movies
class MoviesController < ApplicationController
  def index
    if params[:query].present?

      # only returns movie title with case sensitive exact match
      # @movies = Movie.where(title: params[:query])

      # the `I` before `LIKE` takes care of exact case matching
      # @movies = Movie.where("title ILIKE ?", params[:query])

      # takes care of also searching for entered searched item in the synopsis
      # Security NOTE: this query still prevents sql injection, the usual `?` on preventing sql injections just got replaced by :query
      # Search NOTE: this does not take care of searching for `batman v superman` using only `batman superman`
      # @movies = Movie.where("title ILIKE :query OR synopsis ILIKE :query", query: "%#{params[:query]}%")

      # @@ is postgresSQL's full text search - searching for `jump` will also search for any words associated to jump like jumped, jumping, etc
      # @@ applies above method on each word entered on the search field
      # allows to search for `batman v superman` using these searches: `batman superman`, `superman batman`
      # fears will allow search match for `batman v superman` cause synopsis has word `fear`
      # Search NOTE: this setup won't work with partial search, eg `batman sup` won't search for `batman v superman`
      # Search NOTE: this won't be able to search via movie directors, `nolan` won't yeild any results
      # @movies = Movie.where("title @@ :query OR synopsis @@ :query", query: "%#{params[:query]}%")

      # this setup allows to search for movie directors
      # unsure about the `\` character, could be just for convention but may also break something if removed
      sql_query = " \
        movies.title @@ :query \
        OR movies.synopsis @@ :query \
        OR directors.first_name @@ :query \
        OR directors.last_name @@ :query \
      "
      @movies = Movie.joins(:director).where(sql_query, query: "%#{params[:query]}%")
    else
      @movies = Movie.order(title: :asc)
    end
  end
end
