class BaseObject
  attr_reader :x, :y

  def initialize(x, y)
    @x = x
    @y = y
  end

  def object_type
    raise NotImplementedError
  end

  def update_position(x, y)
    @x = x
    @y = y
  end

  def can_be_pushed_by?(object)
    pushers.include?(object.object_type)
  end

  def pushers
    []
  end
end
