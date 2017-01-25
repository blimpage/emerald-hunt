class Dirt < BaseObject
  def object_type
    :dirt
  end

  def sprite_filename
    "./sprites/dirt.png"
  end

  def crushers
    [:player]
  end
end
