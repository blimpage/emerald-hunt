class Rock < BaseObject
  def object_type
    :rock
  end

  def update
    moved = if can_move_now?
      move(0, 1)
    end

    if !!moved
      @last_move_time = Gosu.milliseconds
    end
  end

  def pushers
    [:player]
  end
end
