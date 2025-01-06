class RecommendationController < ApplicationController
  private

  def load_car_recommendations
    @cars ||= RecommendationEngine.recommend_cars(
      user: user,
      matching_brand: brand_query,
      price_min: price_min,
      price_max: price_max,
      page_size: page_size.to_i,
      page_number: page.to_i
    )
  end

  def user_id
    @user_id ||= params[:id]
  end

  def user
    @user ||= User.find_by(id: user_id)
  end

  def brand_query
    @query ||= params[:query] ||= ""
  end

  def price_min
    @price_min ||= params[:price_min].try(:to_i)
  end

  def price_max
    @price_max ||= params[:price_max].try(:to_i)
  end

  def page
    @page ||= params[:page] ||= RecommendationEngine::DEFAULT_PAGE
  end

  def page_size
    @page_size ||= params[:page_size] ||= RecommendationEngine::DEFAULT_PAGE_SIZE
  end

  def selected_fields(cars)
    cars.as_json
  end
end
