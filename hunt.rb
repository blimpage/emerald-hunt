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
  end

  def update
    @player.update
  end

  def draw
    @board.each_tile do |tile, x_index, y_index|
      x_position = TILE_SIZE + x_index * TILE_SIZE
      y_position = TILE_SIZE + y_index * TILE_SIZE

      if @player.x == x_index && @player.y == y_index
        @font.draw("@@@", x_position, y_position, 1)
      else
        @font.draw("#{x_index}, #{y_index}", x_position, y_position, 0, 1, 1, 0xff_888888)
      end
    end
  end
end

class Board
  def initialize
    @matrix = Array.new(TILES_Y, Array.new(TILES_X))
  end

  def each_tile(&block)
    @matrix.each_with_index do |row, y_index|
      row.each_with_index do |tile, x_index|
        yield(tile, x_index, y_index)
      end
    end
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

  private

  def last_move_delta
    Gosu.milliseconds - @last_move_time
  end

  def can_move_now?
    last_move_delta >= MINIMUM_MOVE_TIME
  end
end

EmeraldHunt.new.show if __FILE__ == $0
