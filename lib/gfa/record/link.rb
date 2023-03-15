require 'gfa/record/has_from_to'

class GFA::Record::Link < GFA::Record
  CODE = :L
  REQ_FIELDS = %i[from from_orient to to_orient overlap]
  OPT_FIELDS = {
    MQ: :i, # Mapping quality
    NM: :i, # Number of mismatches/gaps
    EC: :i, # Read count
    FC: :i, # Fragment count
    KC: :i, # k-mer count
    ID: :Z  # Edge identifier
  }

  REQ_FIELDS.each_index do |i|
    define_method(REQ_FIELDS[i]) { fields[i + 2] }
  end
  OPT_FIELDS.each_key { |i| define_method(i) { fields[i] } }

  include GFA::Record::HasFromTo

  def initialize(from, from_orient, to, to_orient, overlap, *opt_fields)
    @fields = {}
    add_field(2, :Z, from,        /[!-)+-<>-~][!-~]*/)
    add_field(3, :Z, from_orient, /[+-]/)
    add_field(4, :Z, to,          /[!-)+-<>-~][!-~]*/)
    add_field(5, :Z, to_orient,   /[+-]/)
    add_field(6, :Z, overlap,     /\*|([0-9]+[MIDNSHPX=])+/)
    opt_fields.each { |f| add_opt_field(f, OPT_FIELDS) }
  end
end
