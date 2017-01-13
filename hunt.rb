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
    @player.update

    if Gosu::button_down?(Gosu::KbD) && Gosu.milliseconds - @last_debug_dump > 1000
      @last_debug_dump = Gosu.milliseconds
      puts "\n\n\n"
      puts BOARD.inspect
    end
  end

  def draw
    BOARD.each_tile do |tile, x_index, y_index|
      x_position = TILE_SIZE + x_index * TILE_SIZE
      y_position = TILE_SIZE + y_index * TILE_SIZE

      case tile.object_type
      when :player
        @font.draw("@@@", x_position, y_position, 0, 1, 1, 0xff_22FF22)
      when :null_object
        @font.draw("#{x_index}, #{y_index}", x_position, y_position, 0, 1, 1, 0xff_444444)
      when :wall
        @font.draw("WWW", x_position, y_position, 0, 1, 1, 0xff_0099CC)
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
        case rand(100)
        when (0..20)
          Tile.new(Wall.new(x_index, y_index))
        when (21..40)
          Tile.new(Rock.new(x_index, y_index))
        else
          Tile.new(@null_object)
        end
      end
    end
  end

  def each_tile(&block)
    @matrix.each_with_index do |row, y_index|
      row.each_with_index do |tile, x_index|
        yield(tile, x_index, y_index)
      end
    end
  end

  def move_object(moving_object, destination_x, destination_y, x_direction, y_direction)
    return false unless tile_in_bounds?(destination_x, destination_y)

    destination_tile = tile_at(destination_x, destination_y)

    if destination_tile.empty?
      free_tile(moving_object.x, moving_object.y)
      destination_tile.set_contents(moving_object)
      moving_object.update_position(destination_x, destination_y)
      true
    elsif destination_tile.contents.can_be_pushed_by?(moving_object) && move_object(destination_tile.contents, destination_x + x_direction, destination_y + y_direction, x_direction, y_direction)
      free_tile(moving_object.x, moving_object.y)
      destination_tile.set_contents(moving_object)
      moving_object.update_position(destination_x, destination_y)
      true
    else
      false
    end
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
end


class Tile
  attr_reader :contents

  def initialize(contents)
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
