class GFA::RecordSet::SegmentSet < GFA::RecordSet
  CODE = :S
  INDEX_FIELD = 2 # Name: Segment name

  ##
  # Computes the sum of all individual segment lengths
  def total_length
    set.map(&:length).reduce(0, :+)
  end
end
