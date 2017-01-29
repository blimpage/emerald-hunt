class Diamond < BaseObject
  def object_type
    :diamond
  end

  def sprite_filename
    "./sprites/diamond.png"
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
    [:player, :rock, :emerald]
  end

  def can_be_crushed_by?(object, x_direction, y_direction)
    # only be crushed by a rock if the rock is falling from above
    if object.object_type == :rock && y_direction <= 0
      false
    else
      super
    end
  end

  def slippery?
    true
  end

  def score_value
    5
  end

  def get_crushed_by(object)
    increment_score if object.object_type == :player
  end
end
