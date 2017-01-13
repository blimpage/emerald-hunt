class Player < BaseObject
  MINIMUM_MOVE_TIME = 150

  def initialize
    @x = (TILES_X / 2).floor
    @y = (TILES_Y / 2).floor
    @last_move_time = Gosu.milliseconds

    BOARD.set_tile_contents(@x, @y, self)
  end

  def update
    moved = if can_move_now?
      if Gosu::button_down?(Gosu::KbLeft)
        BOARD.move_object(self, @x - 1, @y    , -1, 0 )
      elsif Gosu::button_down?(Gosu::KbRight)
        BOARD.move_object(self, @x + 1, @y    , 1,  0 )
      elsif Gosu::button_down?(Gosu::KbUp)
        BOARD.move_object(self, @x,     @y - 1, 0,  -1)
      elsif Gosu::button_down?(Gosu::KbDown)
        BOARD.move_object(self, @x,     @y + 1, 0,   1)
      end
    end

    if !!moved
      @last_move_time = Gosu.milliseconds
    end
  end

  def object_type
    :player
  end

  private

  def last_move_delta
    Gosu.milliseconds - @last_move_time
  end

  def can_move_now?
    last_move_delta >= MINIMUM_MOVE_TIME
  end
end
