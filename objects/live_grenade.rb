class LiveGrenade < BaseObject
  FUSE_DURATION = 700

  def initialize(*args)
    @detonation_time = Gosu.milliseconds + FUSE_DURATION
    @exploded = false
    super
  end

  def update
    explode if time_to_explode?
  end

  def explode
    @exploded = true
    BOARD.trigger_explosion_at(@x, @y)
  end

  def time_to_explode?
    Gosu.milliseconds >= @detonation_time && !@exploded
  end

  def expired?
    @exploded
  end

  def object_type
    :live_grenade
  end

  def sprite_filename
    "./sprites/grenade.png"
  end
end
