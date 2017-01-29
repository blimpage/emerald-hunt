class Emerald < BaseObject
  def object_type
    :emerald
  end

  def sprite_filename
    "./sprites/emerald.png"
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

  def score_value
    1
  end

  def get_crushed_by(object)
    increment_score if object.object_type == :player
  end
end
