class Rock < BaseObject
  def object_type
    :rock
  end

  def pushers
    [:player]
  end
end
