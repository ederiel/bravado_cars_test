class UsersController < RecommendationController
  # GET users/:id/cars/recommended

  # "user_id": <user id (required)>
  # "query": <car brand name or part of car brand name to filter by (optional)>
  # "price_min": <minimum price (optional)>
  # "price_max": <maximum price (optional)>
  # "page": <page number for pagination (optional, default 1, default page size is 20)>

  def show_recommended_cars
    load_car_recommendations
    if @cars.present?
      render json: @cars, status: :ok, each_serializer: UserCarRecommendationsSerializer
    else
      head :no_content
    end
  end
end
