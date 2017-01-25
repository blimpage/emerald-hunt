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

  def pushers
    [:player]
  end

  def slippery?
    true
  end
end
