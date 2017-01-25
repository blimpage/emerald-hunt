class Dirt < BaseObject
  def object_type
    :dirt
  end

  def crushers
    [:player]
  end
end
