class GFA::Record::Path < GFA::Record
   CODE = :P
   OPT_FIELDS = {}
   def initialize(path_name, segment_name, cigar, *opt_fields)
      @fields = {}
      add_field(2, :Z, path_name, /^[!-)+-<>-~][!-~]*$/)
      add_field(3, :Z, segment_name, /^[!-)+-<>-~][!-~]*$/)
      add_field(4, :Z, cigar, /^\*|([0-9]+[MIDNSHPX=])+$/)
      opt_fields.each{ |f| add_opt_field(f, OPT_FIELDS) }
   end
end
