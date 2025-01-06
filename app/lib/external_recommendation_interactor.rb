require "net/http"

class ExternalRecommendationInteractor
  BASE_URL = "https://bravado-images-production.s3.amazonaws.com/recomended_cars.json"

  def initialize(target_user:)
  	@user = target_user
  end

  def self.call(user:)
    new(target_user: user).call
  end

  def call
    response = send_request(uri)
    handle_response(response)
  end

  private

  attr_reader :user
  attr_reader :last_retrieved_at

  def uri
    @uri ||= URI.parse("#{BASE_URL}?#{user.id}")
  end

  def send_request(http_target)
    @last_retrieved_at = Time.now
    Net::HTTP.get_response(http_target)
  end

  def handle_response(http_response)
    response_data = JSON.parse(http_response.body)

    rest_of_data = {
      user_id: user.id,
      retrieved_at: last_retrieved_at,
      created_at: Time.now,
      updated_at: Time.now
    }

    full_data = response_data.map { |r| r.merge(rest_of_data).with_indifferent_access }

    ActiveRecord::Base.transaction do
      user.user_car_external_recommendations.delete_all
      UserCarExternalRecommendation.insert_all(full_data)
    end
  end
end
