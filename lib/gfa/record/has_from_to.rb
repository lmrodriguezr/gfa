module GFA::Record::HasFromTo
  def from?(segment, orient = nil)
    links_from_to?(segment, orient, true)
  end

  def to?(segment, orient = nil)
    links_from_to?(segment, orient, false)
  end

  ##
  # Extracts all linked segments from +gfa+ (which *must* be indexed)
  def segments(gfa)
    raise "Unindexed GFA" unless gfa.indexed?
    [gfa.segments[from.value], gfa.segments[to.value]]
  end

  ##
  # Include a GFA::Record::Segment +segment+?
  def include?(segment)
    # unless segment.is_a? GFA::Record::Segment
    #   raise "Unrecognized class: #{segment.class}"
    # end
    segment.name == from || segment.name == to
  end

  ##
  # Array of strings with the names of the segments linked by the
  # record
  def segment_names_a
    [from.value, to.value]
  end

  private

    def links_from_to?(segment, orient, from)
      segment = segment_name(segment)
      orient  = orient.value if orient.is_a? GFA::Field
      base_k  = from ? 2 : 4
      segment == fields[base_k].value &&
        (orient.nil? || orient == fields[base_k + 1].value)
    end

    def segment_name(segment)
      segment.is_a?(GFA::Record::Segment) ? segment.name.value :
        segment.is_a?(GFA::Field) ? segment.value : segment
    end
end
