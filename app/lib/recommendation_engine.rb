class RecommendationEngine
  DEFAULT_PAGE_SIZE = 20
  DEFAULT_PAGE = 1

  def self.recommend_cars(user:, matching_brand: nil, price_min: nil, price_max: nil,
                          page_size: nil, page_number: nil)

    page_size ||= DEFAULT_PAGE_SIZE
    page_number ||= DEFAULT_PAGE

    raise ArgumentError, "user required" unless user
    raise ArgumentError, "page_size must be a postitive integer" if page_size.to_i < 1
    raise ArgumentError, "page_number must be a postitive integer" if page_number.to_i < 1

    if price_min.present? && price_max.present? && price_min > price_max
      raise ArgumentError, "price_min #{price_min} greater than price_max #{price_max}"
    end

    offset = (page_number - 1) * page_size
    price_inside_bounds = []
    price_outside_bounds = []

    cars = Car.joins(:brand).left_outer_joins(:user_car_external_recommendations)

    if matching_brand.present?
      pattern = "%#{matching_brand}%"
      cars = cars.where("brands.name ilike :pattern", pattern: pattern)
    end

    if price_max.present?
      cars = cars.where("cars.price <= :price_max", price_max: price_max)
    end

    if price_min.present?
      cars = cars.where("cars.price >= :price_min", price_min: price_min)
    end

    best_match_selector = """
      inner join users on users.id = user_preferred_brands.user_id
      where users.preferred_price_range @> cars.price::bigint
    """ if user.preferred_price_range.present?

    # we do not include the second union at all if there are no price bounds
    good_match_union = """
      union all

      select
        1,
        cars.id
      from cars
      inner join user_preferred_brands on user_preferred_brands.brand_id = cars.brand_id
      and user_preferred_brands.user_id = #{user.id}
      inner join users on users.id = user_preferred_brands.user_id
      where not users.preferred_price_range @> cars.price::bigint
    """ if user.preferred_price_range.present?

    cars = cars.joins(<<~WEIGHT_SUBSELECT
      inner join (
        select
          2 as label,
          cars.id as car_id
        from cars
        inner join user_preferred_brands on user_preferred_brands.brand_id = cars.brand_id
        and user_preferred_brands.user_id = #{user.id}
        #{best_match_selector}

        #{good_match_union}

        union all

        select
          0,
          cars.id
        from cars
        left outer join user_preferred_brands on user_preferred_brands.brand_id = cars.brand_id
        and user_preferred_brands.user_id = #{user.id}
        where user_preferred_brands.brand_id is null
      ) weighted_cars on cars.id = weighted_cars.car_id
    WEIGHT_SUBSELECT
    )

    cars = cars.select("cars.*, user_car_external_recommendations.rank_score, weighted_cars.label")
    # nulls last means we have to do the whole order as a string
    cars = cars.order("label desc, rank_score desc nulls last, price asc")
    cars = cars.limit(page_size).offset(offset)
    
    return cars
  end
end
