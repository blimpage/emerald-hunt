class Bomb < BaseObject
  def object_type
    :bomb
  end

  def sprite_filename
    "./sprites/bomb.png"
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

  def explode_on_contact?
    true
  end

  def pushers
    [:player]
  end

  def explode
    # exploding a bomb triggers another explosion! BOOOM
    BOARD.trigger_explosion_at(@x, @y)
  end
end
