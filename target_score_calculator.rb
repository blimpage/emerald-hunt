class TargetScoreCalculator
  def self.calculate
    total_available_points = 0
    target_percentage = 0.7

    BOARD.each_tile do |tile|
      total_available_points = total_available_points + tile.contents.score_value
    end

    (total_available_points * target_percentage).floor
  end
end
