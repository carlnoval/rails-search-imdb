class TvShow < ApplicationRecord
  # next two lines also exists in movie.rb
  include PgSearch::Model
  multisearchable against: [:title, :synopsis]
end
