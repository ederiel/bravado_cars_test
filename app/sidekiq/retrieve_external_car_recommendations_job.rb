class RetrieveExternalCarRecommendationsJob
  include Sidekiq::Job

  def perform(user_id, retrieved_at_fingerprint)
    user = User.find_by(id: user_id)
    # exit early if the recommendations have been updated since the job was scheduled
    return if user.last_retrieved_at.to_s != retrieved_at_fingerprint
    ExternalRecommendationInteractor.call(user: user)
  end
end
