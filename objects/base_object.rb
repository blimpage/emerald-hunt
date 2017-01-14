class BaseObject
  MINIMUM_MOVE_TIME = 150

  attr_reader :x, :y

  def initialize(x, y)
    @x = x
    @y = y
    touch_last_move_time
  end

  def update
  end

  def object_type
    raise NotImplementedError
  end

  def move(x_direction, y_direction)
    BOARD.try_move(self, x_direction, y_direction)
  end

  def update_position(x, y)
    @x = x
    @y = y
  end

  def can_be_pushed_by?(object)
    pushers.include?(object.object_type)
  end

  def slippable?
    # will this object slip off a slippery object if it lands on the slippery object from above?
    true
  end

  def slippery?
    # will slippable objects slip off this object if they land on the this object from above?
    false
  end

  def pushers
    []
  end

  def touch_last_move_time
    @last_move_time = Gosu.milliseconds
  end

  def can_move_now?
    last_move_delta >= MINIMUM_MOVE_TIME
  end

  def last_move_delta
    Gosu.milliseconds - @last_move_time
  end
end
