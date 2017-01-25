class Rock < BaseObject
  def object_type
    :rock
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
