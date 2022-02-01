class Movie < ApplicationRecord
  belongs_to :director

  # # next two lines are only for multi-search
  # include PgSearch::Model
  # multisearchable against: [:title, :synopsis]

  # including the module from PgSearch
  include PgSearch::Model
  # example: basic w/o association
  # # pg_search_scope is the name givent to the method that will be used in the controller for searching
  # # `:search_by_title_and_synopsis` is just another variable
  # pg_search_scope :search_by_title_and_synopsis,
  #   # will search for title and synopsis on the model
  #   against: [ :title, :synopsis ],
  #   using: {
  #     # tsearch is the equivalent of full-text-search from ActiveRecord search
  #     # prefix is an option to allow partial text search via prefix
  #     # prefix search does not work for suffix
  #     tsearch: { prefix: true } # <-- now `superman batm` will return something!
  #   }

  # example: w/ association
  include PgSearch::Model
  pg_search_scope :global_search,
    against: [ :title, :synopsis ],
    # the only added parameter from the first config
    associated_against: {
      director: [ :first_name, :last_name ]
    },
    using: {
      tsearch: { prefix: true }
    }

  # --- Multi-Search setup --- begin
  
  # This technique is suitable for searching multiple models in one search

  # needs a table `pg_search_documents`: rails g pg_search:migration:multisearch
  # rails db:migrate

  # Step1:
  # schema notes:
  # create_table "pg_search_documents", force: :cascade do |t|
  #   t.text "content"            # what we want to search
  #   t.string "searchable_type"  # what the original type of the object was: movie, tv_show, director
  #   t.bigint "searchable_id"    # what was the id of the searchable_type
  #   t.datetime "created_at", precision: 6, null: false
  #   t.datetime "updated_at", precision: 6, null: false
  #   t.index ["searchable_type", "searchable_id"], name: "index_pg_search_documents_on_searchable"
  # end

  # Step2:
  # next two lines are added here in movie.rb and in tv_show.rb
  include PgSearch::Model
  multisearchable against: [:title, :synopsis]

  # Step3: Execute the following commands to add existing movie and tv_show data in `pg_search_documents`
  # PgSearch::Multisearch.rebuild(Movie)  - adds all information about the movie into `pg_search_documents` via INSERT INTO
  # PgSearch::Multisearch.rebuild(TvShow) - adds all information about the tv_show into `pg_search_documents` via INSERT INTO
  # NOTE: only have to execute previous 2 lines once
  # NOTE: newly create movie/tv_shows will automatically get added into `pg_search_documents`

  # Playing in rails c:
  # results = PgSearch.multisearch('superman')
  # results.first.class returns a `PgSearch::Document` class
  # results.first.searchable returns the serached model

  # --- Multi-Search setup --- end

end
