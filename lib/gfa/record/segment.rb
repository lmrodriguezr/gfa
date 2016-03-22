class GFA::Record::Segment < GFA::Record
   CODE = :S
   OPT_FIELDS = {
      :LN => :i,
      :RC => :i,
      :FC => :i,
      :KC => :i
   }
   def initialize(name, sequence, *opt_fields)
      @fields = {}
      add_field(2, :Z, name, /^[!-)+-<>-~][!-~]*$/)
      add_field(3, :Z, sequence, /^\*|[A-Za-z=.]+$/)
      opt_fields.each{ |f| add_opt_field(f, OPT_FIELDS) }
   end
end
