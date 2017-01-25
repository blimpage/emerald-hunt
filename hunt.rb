# Encoding: UTF-8

require "rubygems"
require "gosu"

Dir[File.join(__dir__, "objects", "*.rb")].each { |file| require file }


TILES_X, TILES_Y = 20, 15
TILE_SIZE = 40


class EmeraldHunt < Gosu::Window
  def initialize
    super(TILES_X * TILE_SIZE + TILE_SIZE * 2, TILES_Y * TILE_SIZE + TILE_SIZE * 2)

    self.caption = "Emerald Hunt"

    @player = Player.new

    @font = Gosu::Font.new(10)

    @last_debug_dump = Gosu.milliseconds
  end

  def update
    BOARD.each_tile do |tile|
      tile.contents.update
    end

    if !@player.activated? && BOARD.everything_still?
      player_position = BOARD.random_blank_tile
      @player.activate_at(player_position.x, player_position.y)
    end

    if Gosu::button_down?(Gosu::KbD) && Gosu.milliseconds - @last_debug_dump > 1000
      @last_debug_dump = Gosu.milliseconds
      puts "\n\n\n"
      puts BOARD.inspect
    end
  end

  def draw
    BOARD.each_tile do |tile|
      x_position = TILE_SIZE + tile.x * TILE_SIZE
      y_position = TILE_SIZE + tile.y * TILE_SIZE

      case tile.object_type
      when :player
        @font.draw("@@@", x_position, y_position, 0, 1, 1, 0xff_22FF22)
      when :null_object
        @font.draw("#{tile.x}, #{tile.y}", x_position, y_position, 0, 1, 1, 0xff_444444)
      when :brick
        @font.draw("BBB", x_position, y_position, 0, 1, 1, 0xff_a20406)
      when :dirt
        @font.draw("DDD", x_position, y_position, 0, 1, 1, 0xff_ab5405)
      when :rock
        @font.draw("RRR", x_position, y_position, 0, 1, 1, 0xff_AAAAAA)
      else
        @font.draw("???", x_position, y_position, 0, 1, 1, 0xff_ff0000)
      end
    end
  end
end


class Board
  def initialize
    @null_object = NullObject.new

    @matrix = Array.new(TILES_Y) do |y_index|
      Array.new(TILES_X) do |x_index|
        contents = case rand(100)
        when (0..15)
          Brick.new(x_index, y_index)
        when (16..30)
          Dirt.new(x_index, y_index)
        when (31..45)
          Rock.new(x_index, y_index)
        else
          @null_object
        end

        Tile.new(x_index, y_index, contents)
      end
    end

    @global_last_move_time = 0
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
    elsif destination_tile.contents.can_be_crushed_by?(moving_object)
      destination_tile.contents.get_crushed_by(moving_object)
      execute_move(moving_object, destination_x, destination_y)

    # try pushing the destination tile's contents out of the way.
    # this will recursively call try_move.
    elsif destination_tile.contents.can_be_pushed_by?(moving_object) &&
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

  def set_tile_contents(x, y, contents)
    tile_at(x, y).set_contents(contents)
  end

  def free_tile(x, y)
    tile_at(x, y).set_contents(@null_object)
  end

  def tile_at(x, y)
    @matrix[y][x]
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
  attr_reader :x, :y, :contents

  def initialize(x, y, contents)
    @x = x
    @y = y
    @contents = contents
  end

  def set_contents(contents)
    @contents = contents
  end

  def object_type
    @contents.object_type
  end

  def empty?
    object_type == :null_object
  end
end

BOARD = Board.new


EmeraldHunt.new.show if __FILE__ == $0
