class RandomObjectGenerator
  def initialize(board)
    @board = board
    @object_set = []
    @object_backlog = []

    objects.each do |object|
      # starting from `@object_set[@object_set.size]` (ie. just past the end of the array),
      # inject `object[:probability]` instances of `object[:class_name]`.
      @object_set.fill(object[:class_name], @object_set.size, object[:probability])
    end
  end

  def objects
    # these probabilities aren't out of 100 or anything, they're just relative to each other.
    [
      { class_name: Brick,      probability: 10 },
      { class_name: Stone,      probability: 5  },
      { class_name: Dirt,       probability: 20 },
      { class_name: Rock,       probability: 20 },
      { class_name: Emerald,    probability: 16 },
      { class_name: Diamond,    probability: 6  },
      { class_name: Grenade,    probability: 2  },
      { class_name: Bomb,       probability: 2  },
      { class_name: NullObject, probability: 20 }
    ]
  end

  def object_can_be_placed_at?(object_class, x, y)
    if object_class == Bomb
      @board.tile_sturdy?(x, y)
    else
      true
    end
  end

  def for_tile(x, y)
    usable_object = nil
    tried_backlog = false

    while usable_object == nil do
      generated_object = if !tried_backlog && @object_backlog.any?
        @object_backlog.shift
      else
        @object_set.sample
      end

      tried_backlog = true

      if object_can_be_placed_at?(generated_object, x, y)
        usable_object = generated_object
      else
        @object_backlog.push(generated_object)
      end
    end

    if usable_object == NullObject
      NULL_OBJECT
    else
      usable_object.new(x, y)
    end
  end
end
