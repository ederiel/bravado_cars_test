class UserRecommendedCarsController < ApplicationController
  # POST user_recommended_cars_controller/show
  # QUERY user_recommended_cars_controller/show
  #   (this is the correct HTTP verb for a request with a body, provided
  #    it is implemented)

  # "user_id": <user id (required)>
  # "query": <car brand name or part of car brand name to filter by (optional)>
  # "price_min": <minimum price (optional)>
  # "price_max": <maximum price (optional)>
  # "page": <page number for pagination (optional, default 1, default page size is 20)>
  def show
    load_car_recommendations
  end
end
