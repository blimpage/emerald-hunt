class BaseObject
  MINIMUM_MOVE_TIME = 150

  attr_reader :x, :y

  def initialize(x, y)
    @x = x
    @y = y
    @last_move_time = Gosu.milliseconds
  end

  def update
  end

  def object_type
    raise NotImplementedError
  end

  def move(x_direction, y_direction)
    BOARD.move_object(self, x_direction, y_direction)
  end

  def update_position(x, y)
    @x = x
    @y = y
  end

  def can_be_pushed_by?(object)
    pushers.include?(object.object_type)
  end

  def pushers
    []
  end

  def can_move_now?
    last_move_delta >= MINIMUM_MOVE_TIME
  end

  def last_move_delta
    Gosu.milliseconds - @last_move_time
  end
end
