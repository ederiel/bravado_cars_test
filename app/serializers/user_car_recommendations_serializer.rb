class UserCarRecommendationsSerializer < ActiveModel::Serializer
  attributes :id, :brand, :price, :model, :rank_score, :label

  def brand
    { id: object.brand.id, name: object.brand.name }
  end

  def label
    case object.label
      when 2
        "best_match"
      when 1
        "good_match"
      else
        nil
    end
  end
end
