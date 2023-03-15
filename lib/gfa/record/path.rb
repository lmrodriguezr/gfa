class GFA::Record::Path < GFA::Record
  CODE = :P
  REQ_FIELDS = %i[path_name segment_names overlaps]
  OPT_FIELDS = {}

  REQ_FIELDS.each_index do |i|
    define_method(REQ_FIELDS[i]) { fields[i + 2] }
  end

  alias segment_name segment_names
  alias cigar overlaps

  def initialize(path_name, segment_names, overlaps, *opt_fields)
    @fields = {}
    add_field(2, :Z, path_name,     /[!-)+-<>-~][!-~]*/)
    add_field(3, :Z, segment_names, /[!-)+-<>-~][!-~]*/)
    add_field(4, :Z, overlaps,      /\*|([0-9]+[MIDNSHPX=]|[-+]?[0-9]+J|.)+/)
    opt_fields.each { |f| add_opt_field(f, OPT_FIELDS) }
  end

  ##
  # Array of segment names (without orientations) as strings
  def segment_names_a
    segment_names.value.split(/[,;]/).map { |i| i.gsub(/[+-]$/, '') }
  end

  ##
  # Extracts all linked segments from +gfa+ (which *must* be indexed)
  def segments(gfa)
    raise "Unindexed GFA" unless gfa.indexed?
    segment_names_a.map do |name|
      gfa.segments[name]
    end
  end

  ##
  # Includes a GFA::Record::Segment +segment+?
  def include?(segment)
    # unless segment.is_a? GFA::Record::Segment
    #   raise "Unrecognized class: #{segment.class}"
    # end

    segment_names_a.any? { |name| segment.name == name }
  end
end
