# Encoding: UTF-8

require 'rubygems'
require 'gosu'

TILES_X, TILES_Y = 20, 15
TILE_SIZE = 40

class EmeraldHunt < Gosu::Window
  def initialize
    super(TILES_X * TILE_SIZE + TILE_SIZE * 2, TILES_Y * TILE_SIZE + TILE_SIZE * 2)
    
    self.caption = "Emerald Hunt"
    
    @matrix = Array.new(TILES_Y, Array.new(TILES_X))

    @font = Gosu::Font.new(10)
  end
  
  def update
    
  end
  
  def draw
    @matrix.each_with_index do |row, y_index|
      row.each_with_index do |tile, x_index|
        x_position = TILE_SIZE + x_index * TILE_SIZE
        y_position = TILE_SIZE + y_index * TILE_SIZE
        @font.draw("#{x_index}, #{y_index}", x_position, y_position, 0)
      end
    end
  end
end

EmeraldHunt.new.show if __FILE__ == $0
