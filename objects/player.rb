class Player < BaseObject
  def initialize(activate_immediately = false)
    @activated = false
    activate if activate_immediately
  end

  def update
    if can_move_now?
      # move(x,y) will return either true or false based on whether the
      # move was successful. we'll set @in_motion using the result of this.
      # perhaps not the most readable, but it works nicely.
      @in_motion = if Gosu::button_down?(Gosu::KbLeft)
        move(-1,  0)
      elsif Gosu::button_down?(Gosu::KbRight)
        move( 1,  0)
      elsif Gosu::button_down?(Gosu::KbUp)
        move( 0, -1)
      elsif Gosu::button_down?(Gosu::KbDown)
        move( 0,  1)
      else
        false
      end
    end
  end

  def activate_at(x, y)
    @x = x
    @y = y

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

  def crushers
    [:rock]
  end

  def can_be_crushed_by?(object)
    crushers.include?(object.object_type) && object.in_motion
  end

  def get_crushed_by(object)
    GAME_STATE[:game_over] = true
  end

  def activated?
    !!@activated
  end
end
