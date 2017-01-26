class LiveGrenade < BaseObject
  FUSE_TIME = 500

  def initialize(*args)
    @detonation_time = Gosu.milliseconds + FUSE_TIME
    @expired = false
    super
  end

  def update
    explode if time_to_explode?
  end

  def explode
    puts 'boom'
    @expired = true
  end

  def time_to_explode?
    Gosu.milliseconds >= @detonation_time
  end

  def expired?
    @expired
  end

  def object_type
    :live_grenade
  end

  def sprite_filename
    "./sprites/grenade.png"
  end
end
