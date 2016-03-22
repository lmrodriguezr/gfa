class GFA::Record::Containment < GFA::Record
   CODE = :C
   OPT_FIELDS = {
      :RC => :i,
      :NM => :i
   }
   def initialize(from, from_orient, to, to_orient, pos, overlap, *opt_fields)
      @fields = {}
      add_field(2, :Z, from, /^[!-)+-<>-~][!-~]*$/)
      add_field(3, :Z, from_orient, /^+|-$/)
      add_field(4, :Z, to, /^[!-)+-<>-~][!-~]*$/)
      add_field(5, :Z, to_orient, /^+|-$/)
      add_field(6, :i, pos, /^[0-9]*$/)
      add_field(7, :Z, overlap, /^\*|([0-9]+[MIDNSHPX=])+$/)
      opt_fields.each{ |f| add_opt_field(f, OPT_FIELDS) }
   end
end
