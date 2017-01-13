# Encoding: UTF-8

require 'rubygems'
require 'gosu'

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
        @font.draw("@@@", x_position, y_position, 1)
      when :null_object
        @font.draw("#{x_index}, #{y_index}", x_position, y_position, 0, 1, 1, 0xff_888888)
      when :wall
        @font.draw("WWW", x_position, y_position, 0, 1, 1, 0xff_0099CC)
      else
        @font.draw("???", x_position, y_position, 0, 1, 1, 0xff_ff0000)
      end
    end
  end
end


class Board
  def initialize
    @null_object = NullObject.new
    @matrix = Array.new(TILES_Y) do
      Array.new(TILES_X) do
        if rand(100) < 20
          Tile.new(Wall.new)
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

  def move_object(moving_object, destination_x, destination_y)
    if tile_in_bounds?(destination_x, destination_y) && tile_at(destination_x, destination_y).empty? # || destination_tile.contents.can_be_moved_by?(moving_object)
      free_tile(moving_object.x, moving_object.y)
      tile_at(destination_x, destination_y).set_contents(moving_object)
      moving_object.update_position(destination_x, destination_y)
      true
    else
      false
    end
  end

  def set_tile_contents(x_index, y_index, contents)
    tile_at(x_index, y_index).set_contents(contents)
  end

  def free_tile(x_index, y_index)
    tile_at(x_index, y_index).set_contents(@null_object)
  end

  def tile_at(x_index, y_index)
    @matrix[y_index][x_index]
  end

  def tile_in_bounds?(x, y)
    x.between?(0, TILES_X - 1) && y.between?(0, TILES_Y - 1)
  end
end


class Tile
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


class NullObject
  def initialize
  end

  def object_type
    :null_object
  end
end


class Wall
  def initialize
  end

  def object_type
    :wall
  end
end


class Player
  attr_reader :x, :y

  MINIMUM_MOVE_TIME = 150

  def initialize
    @x = (TILES_X / 2).floor
    @y = (TILES_Y / 2).floor
    @last_move_time = Gosu.milliseconds

    BOARD.set_tile_contents(@x, @y, self)
  end

  def update
    moved = if can_move_now?
      if Gosu::button_down?(Gosu::KbLeft)
        BOARD.move_object(self, @x - 1, @y    )
      elsif Gosu::button_down?(Gosu::KbRight)
        BOARD.move_object(self, @x + 1, @y    )
      elsif Gosu::button_down?(Gosu::KbUp)
        BOARD.move_object(self, @x,     @y - 1)
      elsif Gosu::button_down?(Gosu::KbDown)
        BOARD.move_object(self, @x,     @y + 1)
      end
    end

    if !!moved
      @last_move_time = Gosu.milliseconds
    end
  end

  def update_position(x, y)
    @x = x
    @y = y
  end

  def object_type
    :player
  end

  private

  def last_move_delta
    Gosu.milliseconds - @last_move_time
  end

  def can_move_now?
    last_move_delta >= MINIMUM_MOVE_TIME
  end
end

BOARD = Board.new


EmeraldHunt.new.show if __FILE__ == $0
