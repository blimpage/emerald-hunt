class Rock < BaseObject
  def object_type
    :rock
  end

  def update
    moved = if can_move_now?
      move(0, 1)
    end

    touch_last_move_time if !!moved
  end

  def pushers
    [:player]
  end

  def slippery?
    true
  end
end
