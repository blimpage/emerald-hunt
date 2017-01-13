class Player < BaseObject
  def initialize
    @x = (TILES_X / 2).floor
    @y = (TILES_Y / 2).floor
    @last_move_time = Gosu.milliseconds

    BOARD.set_tile_contents(@x, @y, self)
  end

  def update
    moved = if can_move_now?
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

    if !!moved
      @last_move_time = Gosu.milliseconds
    end
  end

  def object_type
    :player
  end
end
