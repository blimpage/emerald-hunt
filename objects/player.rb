class Player < BaseObject
  attr_reader :grenade_count

  def initialize(activate_immediately = false)
    @activated = false
    @sprite = Gosu::Image.new(sprite_filename, retro: true)
    @grenade_count = 0

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

      if Gosu::button_down?(Gosu::KbSpace) && can_drop_grenade_now?
        drop_grenade
      end
    end
  end

  def activate_at(x, y)
    update_position(x, y)

    BOARD.set_tile_contents(@x, @y, self)

    @last_move_time = Gosu.milliseconds
    @last_grenade_drop_time = Gosu.milliseconds

    @activated = true
  end

  def drop_grenade
    @grenade_count -= 1
    @last_grenade_drop_time = Gosu.milliseconds
    BOARD.tile_at(@x, @y).set_secondary_contents(LiveGrenade.new(@x, @y))
  end

  def can_drop_grenade_now?
    @grenade_count.positive? &&
      @in_motion == false &&
      can_move_now? &&
      Gosu.milliseconds - @last_grenade_drop_time >= MINIMUM_MOVE_TIME &&
      BOARD.tile_at(@x, @y).secondary_contents? == false
  end

  def object_type
    :player
  end

  def sprite_filename
    "./sprites/player.png"
  end

  def slippable?
    false
  end

  def crushers
    [:rock, :emerald, :diamond]
  end

  def can_be_crushed_by?(object, x_direction, y_direction)
    crushers.include?(object.object_type) && object.in_motion
  end

  def get_crushed_by(object)
    GAME_STATE[:game_over] = true
  end

  def collect_grenade
    @grenade_count += 1
  end

  def activated?
    !!@activated
  end
end
