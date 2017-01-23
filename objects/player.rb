class Player < BaseObject
  def initialize(activate_immediately = false)
    @activated = false
    activate if !!activate_immediately
  end

  def update
    if can_move_now?
      if Gosu::button_down?(Gosu::KbLeft)
        move(-1,  0)
      elsif Gosu::button_down?(Gosu::KbRight)
        move( 1,  0)
      elsif Gosu::button_down?(Gosu::KbUp)
        move( 0, -1)
      elsif Gosu::button_down?(Gosu::KbDown)
        move( 0,  1)
      end
    end
  end

  def activate
    @x = (TILES_X / 2).floor
    @y = (TILES_Y / 2).floor

    BOARD.set_tile_contents(@x, @y, self)

    @last_move_time = Gosu.milliseconds

    @activated = true
  end

  def object_type
    :player
  end

  def slippable?
    false
  end

  def activated?
    !!@activated
  end
end
