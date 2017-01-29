class Exit < BaseObject
  def object_type
    :exit
  end

  def sprite_filename
    "./sprites/exit.png"
  end

  def slippery?
    true
  end

  def crushers
    [:player]
  end

  def get_crushed_by(object)
    if object.object_type == :player
      GAME_STATE[:game_won] = true
    end
  end
end
