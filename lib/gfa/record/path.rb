class GFA::Record::Path < GFA::Record
  CODE = :P
  REQ_FIELDS = %i[path_name segment_name cigar]
  OPT_FIELDS = {}

  REQ_FIELDS.each_index do |i|
    define_method(REQ_FIELDS[i]) { fields[i + 2] }
  end

  alias overlaps cigar

  def initialize(path_name, segment_name, cigar, *opt_fields)
    @fields = {}
    add_field(2, :Z, path_name, /^[!-)+-<>-~][!-~]*$/)
    add_field(3, :Z, segment_name, /^[!-)+-<>-~][!-~]*$/)
    add_field(4, :Z, cigar, /^\*|([0-9]+[MIDNSHPX=])+$/)
    opt_fields.each { |f| add_opt_field(f, OPT_FIELDS) }
  end
end
