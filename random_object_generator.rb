class RandomObjectGenerator
  def initialize
    @object_set = []

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

  def for_tile(x, y)
    object_class = @object_set.sample

    if object_class == NullObject
      NULL_OBJECT
    else
      object_class.new(x, y)
    end
  end
end
