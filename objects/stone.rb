class Stone < BaseObject
  def object_type
    :stone
  end

  def sprite_filename
    "./sprites/stone.png"
  end

  def slippery?
    true
  end
end
