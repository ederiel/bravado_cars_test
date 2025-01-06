class ExternalCarRecommendationsManager
  def initialize(user_list:)
    @users = user_list
    if @users.empty?
      @users = User.all
    end
  end

  def self.call(users: [])
    new(user_list: users).call
  end

  def call
    users.each do |user|
      fingerprint = user.last_retrieved_at.to_s
      RetrieveExternalCarRecommendationsJob.perform_async(user.id, fingerprint)
    end
  end

  private

  attr_reader :users
end
