require 'gfa/record/has_from_to'

class GFA::Record::Jump < GFA::Record
  CODE = :J
  REQ_FIELDS = %i[from from_orient to to_orient distance]
  OPT_FIELDS = {
    SC: :i  # 1 indicates indirect shortcut connections. Only 0/1 allowed.
  }

  REQ_FIELDS.each_index do |i|
    define_method(REQ_FIELDS[i]) { fields[i + 2] }
  end
  OPT_FIELDS.each_key { |i| define_method(i) { fields[i] } }

  include GFA::Record::HasFromTo

  def initialize(from, from_orient, to, to_orient, distance, *opt_fields)
    @fields = {}
    add_field(2, :Z, from,        /[!-)+-<>-~][!-~]*/)
    add_field(3, :Z, from_orient, /[+-]/)
    add_field(4, :Z, to,          /[!-)+-<>-~][!-~]*/)
    add_field(5, :Z, to_orient,   /[+-]/)
    add_field(6, :Z, distance,    /\*|[-+]?[0-9]+/)
    opt_fields.each { |f| add_opt_field(f, OPT_FIELDS) }
  end
end
