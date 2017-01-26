class Grenade < BaseObject
  def object_type
    :grenade
  end

  def sprite_filename
    "./sprites/grenade.png"
  end

  def crushers
    [:player]
  end

  def get_crushed_by(object)
    if object.object_type == :player
      object.collect_grenade
    end
  end
end
