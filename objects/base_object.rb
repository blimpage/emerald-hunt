class BaseObject
  MINIMUM_MOVE_TIME = 150

  attr_reader :x, :y, :in_motion, :sprite

  def initialize(x, y)
    @x = x
    @y = y
    @in_motion = false
    @sprite = Gosu::Image.new(sprite_filename, retro: true)
    touch_last_move_time
  end

  def update
  end

  def draw(x, y)
    sprite.draw(x, y, 0)
  end

  def object_type
    raise NotImplementedError
  end

  def sprite_filename
    raise NotImplementedError
  end

  def move(x_direction, y_direction)
    BOARD.try_move(self, x_direction, y_direction)
  end

  def update_position(x, y)
    @x = x
    @y = y
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
    # object_types that can push this object around
    []
  end

  def crushers
    # object_types that can crush and destroy this object
    []
  end

  def can_be_pushed_by?(object)
    pushers.include?(object.object_type)
  end

  def can_be_crushed_by?(object)
    crushers.include?(object.object_type)
  end

  def get_crushed_by(object)
    # optional callback for the object to do anything it needs to in its
    # last few precious seconds of life
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
