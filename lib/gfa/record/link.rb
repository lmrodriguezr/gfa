class GFA::Record::Link < GFA::Record
   CODE = :L
   REQ_FIELDS = [:from, :from_orient, :to, :to_orient, :overlap]
   OPT_FIELDS = {
      :MQ => :i,
      :NM => :i,
      :EC => :i,
      :FC => :i,
      :KC => :i
   }
   
   REQ_FIELDS.each_index do |i|
      define_method(REQ_FIELDS[i]) { fields[i+2] }
   end

   def initialize(from, from_orient, to, to_orient, overlap, *opt_fields)
      @fields = {}
      add_field(2, :Z, from, /^[!-)+-<>-~][!-~]*$/)
      add_field(3, :Z, from_orient, /^+|-$/)
      add_field(4, :Z, to, /^[!-)+-<>-~][!-~]*$/)
      add_field(5, :Z, to_orient, /^+|-$/)
      add_field(6, :Z, overlap, /^\*|([0-9]+[MIDNSHPX=])+$/)
      opt_fields.each{ |f| add_opt_field(f, OPT_FIELDS) }
   end

   
   def from?(segment, orient=nil)
      links_from_to?(segment, orient, true)
   end
   
   def to?(segment, orient=nil)
      links_from_to?(segment, orient, false)
   end

   private

      def links_from_to?(segment, orient, from)
	 segment = segment.value if segment.is_a? GFA::Field
	 segment = segment.name  if segment.is_a? GFA::Record::Segment
	 orient  = orient.value  if orient.is_a?  GFA::Field
	 segment==fields[from ? 2 : 4].value and
	    (orient.nil? or orient==fields[from ? 3 : 5].value)
      end

end
