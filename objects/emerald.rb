class Emerald < BaseObject
  def object_type
    :emerald
  end

  def update
    if can_move_now?
      if move(0, 1)
        @in_motion = true
      else
        @in_motion = false
      end
    end
  end

  def crushers
    [:player]
  end

  def slippery?
    true
  end

  def get_crushed_by(object)
    if object.object_type == :player
      GAME_STATE[:score] = GAME_STATE[:score] + 1
    end
  end
end
