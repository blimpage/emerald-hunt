class Brick < BaseObject
  def object_type
    :brick
  end

  def sprite_filename
    "./sprites/brick.png"
  end

  def flammable?
    false
  end
end
