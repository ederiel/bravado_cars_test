namespace :recs do
  desc "schedule updating recommendations for all user"
  task get_all: :environment do
    ExternalCarRecommendationsManager.call
  end
end
