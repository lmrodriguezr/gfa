class GFA::Record::Containment < GFA::Record
  CODE = :C
  REQ_FIELDS = %i[from from_orient to to_orient pos overlap]
  OPT_FIELDS = {
    RC: :i, # Read coverage
    NM: :i, # Number of mismatches/gaps
    ID: :Z  # Edge identifier
  }

  REQ_FIELDS.each_index do |i|
    define_method(REQ_FIELDS[i]) { fields[i + 2] }
  end
  OPT_FIELDS.each_key { |i| define_method(i) { fields[i] } }

  alias container from
  alias container_orient from_orient
  alias contained to
  alias contained_orient to_orient

  def initialize(from, from_orient, to, to_orient, pos, overlap, *opt_fields)
    @fields = {}
    add_field(2, :Z, from,        /[!-)+-<>-~][!-~]*/)
    add_field(3, :Z, from_orient, /[+-]/)
    add_field(4, :Z, to,          /[!-)+-<>-~][!-~]*/)
    add_field(5, :Z, to_orient,   /[+-]/)
    add_field(6, :i, pos,         /[0-9]*/)
    add_field(7, :Z, overlap,     /\*|([0-9]+[MIDNSHPX=])+/)
    opt_fields.each { |f| add_opt_field(f, OPT_FIELDS) }
  end
end
