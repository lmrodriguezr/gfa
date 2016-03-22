class GFA::Record::Link < GFA::Record
   CODE = :L
   OPT_FIELDS = {
      :MQ => :i,
      :NM => :i,
      :EC => :i,
      :FC => :i,
      :KC => :i
   }
   def initialize(from, from_orient, to, to_orient, overlap, *opt_fields)
      @fields = {}
      add_field(2, :Z, from, /^[!-)+-<>-~][!-~]*$/)
      add_field(3, :Z, from_orient, /^+|-$/)
      add_field(4, :Z, to, /^[!-)+-<>-~][!-~]*$/)
      add_field(5, :Z, to_orient, /^+|-$/)
      add_field(6, :Z, overlap, /^\*|([0-9]+[MIDNSHPX=])+$/)
      opt_fields.each{ |f| add_opt_field(f, OPT_FIELDS) }
   end
end
