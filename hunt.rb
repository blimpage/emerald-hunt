# Encoding: UTF-8

require "rubygems"
require "gosu"

Dir[File.join(__dir__, "objects", "*.rb")].each { |file| require file }

require "./random_object_generator"
require "./target_score_calculator"

TILES_X, TILES_Y = 40, 20
TILE_SIZE = 16
GAME_STATE = {
  game_won: false,
  game_over: false,
  target_score: 50,
  score: 0
}
NULL_OBJECT = NullObject.new


class EmeraldHunt < Gosu::Window
  def initialize
    super((TILES_X * TILE_SIZE + TILE_SIZE * 2) * 2, (TILES_Y * TILE_SIZE + TILE_SIZE * 2) * 2)

    self.caption = "Emerald Hunt"

    @player = Player.new

    @font = Gosu::Font.new(10)

    @last_debug_dump = Gosu.milliseconds
  end

  def update
    unless GAME_STATE[:game_over] || GAME_STATE[:game_won]
      BOARD.each_tile do |tile|
        tile.update
      end

      if !@player.activated? && BOARD.everything_still?
        player_position = BOARD.random_blank_tile
        @player.activate_at(player_position.x, player_position.y)

        exit_position = BOARD.random_blank_tile
        exit_position.set_contents(Exit.new(exit_position.x, exit_position.y))

        GAME_STATE[:target_score] = TargetScoreCalculator.calculate
      end
    end

    if Gosu::button_down?(Gosu::KbD) && Gosu.milliseconds - @last_debug_dump > 1000
      @last_debug_dump = Gosu.milliseconds
      puts "\n\n\n"
      puts BOARD.inspect
    end
  end

  def draw
    self.scale(2) do
      BOARD.each_tile do |tile|
        x_position = TILE_SIZE + tile.x * TILE_SIZE
        y_position = TILE_SIZE + tile.y * TILE_SIZE

        tile.draw(x_position, y_position)
      end

      hud_text = "SCORE: #{GAME_STATE[:score]} | GOAL: #{GAME_STATE[:target_score]} | GRENADES: #{@player.grenade_count}"
      @font.draw(hud_text, TILE_SIZE, TILE_SIZE * 0.4, 0)

      if GAME_STATE[:game_over]
        x = (TILES_X * TILE_SIZE + TILE_SIZE * 2) / 2
        y = (TILES_Y * TILE_SIZE + TILE_SIZE * 2) / 2
        @font.draw_rel("GAME OVER", x, y, 99, 0.5, 0.5, 10, 10, 0xff_ff0000)
      elsif GAME_STATE[:game_won]
        x = (TILES_X * TILE_SIZE + TILE_SIZE * 2) / 2
        y = (TILES_Y * TILE_SIZE + TILE_SIZE * 2) / 2
        @font.draw_rel("CONGRATULATIONS", x, y, 99, 0.5, 0.5, 7, 7, 0xff_ff0000)
      end
    end
  end
end


class Board
  def initialize
    @random_object_generator = RandomObjectGenerator.new
    @global_last_move_time = 0

    @matrix = Array.new(TILES_Y) do |y|
      Array.new(TILES_X) do |x|
        Tile.new(x, y, @random_object_generator.for_tile(x, y))
      end
    end
  end

  def each_tile(&block)
    @matrix.flatten.each do |tile|
      yield(tile)
    end
  end

  def try_move(moving_object, x_direction, y_direction)
    destination_x = moving_object.x + x_direction
    destination_y = moving_object.y + y_direction

    return false unless tile_in_bounds?(destination_x, destination_y)

    destination_tile = tile_at(destination_x, destination_y)

    # move into the tile if it's empty
    if destination_tile.empty?
      execute_move(moving_object, destination_x, destination_y)

    # try crushing the destination tile's contents.
    elsif destination_tile.contents.can_be_crushed_by?(moving_object, x_direction, y_direction)
      destination_tile.contents.get_crushed_by(moving_object)
      execute_move(moving_object, destination_x, destination_y)

    # try pushing the destination tile's contents out of the way.
    # this will recursively call try_move.
    elsif y_direction >= 0 && # objects cannot be pushed upwards.
          destination_tile.contents.can_be_pushed_by?(moving_object) &&
          try_move(destination_tile.contents, x_direction, y_direction)
      execute_move(moving_object, destination_x, destination_y)

    # if the object wants to move straight down, check if the destination tile's contents
    # are slippery - that means we can try moving to the left or right instead.
    # try left first
    elsif y_direction.positive? &&
          x_direction.zero? &&
          destination_tile.contents.slippery? &&
          moving_object.slippable? &&
          tile_in_bounds?(moving_object.x - 1, moving_object.y + 1) &&
          tile_at(moving_object.x - 1, moving_object.y + 1).empty? &&
          tile_in_bounds?(moving_object.x - 1, moving_object.y) &&
          tile_at(moving_object.x - 1, moving_object.y).empty?
      execute_move(moving_object, moving_object.x - 1, moving_object.y)

    # then try right
    elsif y_direction.positive? &&
          x_direction.zero? &&
          destination_tile.contents.slippery? &&
          moving_object.slippable? &&
          tile_in_bounds?(moving_object.x + 1, moving_object.y + 1) &&
          tile_at(moving_object.x + 1, moving_object.y + 1).empty? &&
          tile_in_bounds?(moving_object.x + 1, moving_object.y) &&
          tile_at(moving_object.x + 1, moving_object.y).empty?
      execute_move(moving_object, moving_object.x + 1, moving_object.y)

    # if the object is falling on top of something and it should explode on contact,
    # explode it
    elsif y_direction.positive? &&
          x_direction.zero? &&
          moving_object.explode_on_contact?
      moving_object.explode
      false

    # or if the object is falling on top of something else that should explode on contact,
    # explode the other thing
    elsif y_direction.positive? &&
          x_direction.zero? &&
          destination_tile.contents.explode_on_contact?
      destination_tile.contents.explode
      false

    else
      false
    end
  end

  def execute_move(moving_object, destination_x, destination_y)
    free_tile(moving_object.x, moving_object.y)
    tile_at(destination_x, destination_y).set_contents(moving_object)
    moving_object.update_position(destination_x, destination_y)
    moving_object.touch_last_move_time
    touch_global_last_move_time
    true
  end

  def trigger_explosion_at(x, y)
    neighbouring_tiles_of(x, y).each do |tile|
      tile.mark_for_explosion
    end

    # we also need to deal with the contents of the tile where the explosion started.
    origin_tile = tile_at(x, y)
    unless origin_tile.empty?
      if origin_tile.object_type == :player
        # if the player's there, kill 'em.
        origin_tile.mark_for_explosion
      else
        # if anything else is there, just delete it.
        free_tile(x, y)
      end
    end
  end

  def set_tile_contents(x, y, contents)
    tile_at(x, y).set_contents(contents)
  end

  def free_tile(x, y)
    tile_at(x, y).set_contents(NULL_OBJECT)
  end

  def tile_at(x, y)
    @matrix[y][x]
  end

  def neighbouring_tiles_of(x, y)
    # return all of the tiles surrounding a coordinate
    [
      # wow this is like a visual representation of the coordinates we're setting up.
      # that's deep, man.
      [x - 1, y - 1], [x    , y - 1], [x + 1, y - 1],
      [x - 1, y    ],                 [x + 1, y    ],
      [x - 1, y + 1], [x    , y + 1], [x + 1, y + 1]
    ].select { |coordinate_set|
      tile_in_bounds?(*coordinate_set)
    }.map { |coordinate_set|
      tile_at(*coordinate_set)
    }
  end

  def tile_in_bounds?(x, y)
    x.between?(0, TILES_X - 1) && y.between?(0, TILES_Y - 1)
  end

  def random_blank_tile
    @matrix.flatten.select(&:empty?).sample
  end

  def touch_global_last_move_time
    @global_last_move_time = Gosu.milliseconds
  end

  def everything_still?
    Gosu.milliseconds - @global_last_move_time > 200
  end
end


class Tile
  attr_reader :x, :y, :contents, :secondary_contents

  def initialize(x, y, contents)
    @x = x
    @y = y
    @contents = contents
    @secondary_contents = NULL_OBJECT
    # secondary_contents is used for objects that need to temporarily occupy
    # the same tile as another object, like live grenades. it's dumb.
    @about_to_explode = false
  end

  def update
    if @about_to_explode
      @contents.explode
      @contents = Explosion.new(@x, @y)
      @about_to_explode = false
    end

    @contents.update

    if secondary_contents?
      @secondary_contents.update
      set_secondary_contents(NULL_OBJECT) if @secondary_contents.expired?
    end
  end

  def draw(x_position, y_position)
    if object_type != :null_object
      @contents.draw(x_position, y_position)
    elsif secondary_contents?
      @secondary_contents.draw(x_position, y_position)
    end
  end

  def set_contents(contents)
    @contents = contents
  end

  def set_secondary_contents(secondary_contents)
    @secondary_contents = secondary_contents
  end

  def object_type
    @contents.object_type
  end

  def empty?
    object_type == :null_object && @secondary_contents.object_type == :null_object
  end

  def secondary_contents?
    @secondary_contents.object_type != :null_object
  end

  def mark_for_explosion
    if @contents.flammable?
      @about_to_explode = true
    end
  end
end

BOARD = Board.new


EmeraldHunt.new.show if __FILE__ == $0
