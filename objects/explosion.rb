class Explosion < BaseObject
  BURN_DURATION = 500

  def initialize(*args)
    @burn_out_time = Gosu.milliseconds + BURN_DURATION
    @burnt_out = false
    super
  end

  def update
    if !@burnt_out && time_to_burn_out?
      @burnt_out = true
      BOARD.free_tile(@x, @y)
    end
  end

  def time_to_burn_out?
    Gosu.milliseconds >= @burn_out_time
  end

  def object_type
    :explosion
  end

  def sprite_filename
    "./sprites/explosion.png"
  end
end
