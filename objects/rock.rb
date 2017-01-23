class Rock < BaseObject
  def object_type
    :rock
  end

  def update
    if can_move_now?
      move(0, 1)
    end
  end

  def pushers
    [:player]
  end

  def slippery?
    true
  end
end
