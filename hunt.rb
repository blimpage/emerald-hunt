# Encoding: UTF-8

require 'rubygems'
require 'gosu'

TILES_X, TILES_Y = 20, 15
TILE_SIZE = 40

class EmeraldHunt < Gosu::Window
  def initialize
    super(TILES_X * TILE_SIZE + TILE_SIZE * 2, TILES_Y * TILE_SIZE + TILE_SIZE * 2)

    self.caption = "Emerald Hunt"

    @board = Board.new
    @player = Player.new

    @font = Gosu::Font.new(10)

    @last_debug_dump = Gosu.milliseconds
  end

  def update
    @board.free_tile(@player.x, @player.y)
    @player.update
    @board.set_tile_contents(@player.x, @player.y, @player)

    if Gosu::button_down?(Gosu::KbD) && Gosu.milliseconds - @last_debug_dump > 1000
      @last_debug_dump = Gosu.milliseconds
      puts "\n\n\n"
      puts @board.inspect
    end
  end

  def draw
    @board.each_tile do |tile, x_index, y_index|
      x_position = TILE_SIZE + x_index * TILE_SIZE
      y_position = TILE_SIZE + y_index * TILE_SIZE

      case tile.object_type
      when :player
        @font.draw("@@@", x_position, y_position, 1)
      when :null_object
        @font.draw("#{x_index}, #{y_index}", x_position, y_position, 0, 1, 1, 0xff_888888)
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
        Tile.new(@null_object)
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

  def set_tile_contents(x_index, y_index, contents)
    tile_at(x_index, y_index).set_contents(contents)
  end

  def free_tile(x_index, y_index)
    tile_at(x_index, y_index).set_contents(@null_object)
  end

  def tile_at(x_index, y_index)
    @matrix[y_index][x_index]
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
end

class NullObject
  def initialize
  end

  def object_type
    :null_object
  end
end

class Player
  attr_reader :x, :y

  MINIMUM_MOVE_TIME = 150

  def initialize
    @x = (TILES_X / 2).floor
    @y = (TILES_Y / 2).floor
    @last_move_time = Gosu.milliseconds
  end

  def update
    if can_move_now?
      if Gosu::button_down?(Gosu::KbLeft)
        if @x > 0
          @x = @x - 1
          @last_move_time = Gosu.milliseconds
        end
      elsif Gosu::button_down?(Gosu::KbRight)
        if @x < TILES_X - 1
          @x = @x + 1
          @last_move_time = Gosu.milliseconds
        end
      elsif Gosu::button_down?(Gosu::KbUp)
        if @y > 0
          @y = @y - 1
          @last_move_time = Gosu.milliseconds
        end
      elsif Gosu::button_down?(Gosu::KbDown)
        if @y < TILES_Y - 1
          @y = @y + 1
          @last_move_time = Gosu.milliseconds
        end
      end
    end
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

EmeraldHunt.new.show if __FILE__ == $0
