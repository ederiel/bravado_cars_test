class CreateUserCarExternalRecommendations < ActiveRecord::Migration[6.1]
  def change
    create_table :user_car_external_recommendations do |t|
      t.references :user, null: false, foreign_key: true
      t.references :car, null: false, foreign_key: true
      t.float :rank_score, null: false

      t.timestamps
      t.datetime :retrieved_at, null: false

      t.index [:rank_score], name: :index_user_car_external_recommendations_on_rank_score
    end
  end
end
