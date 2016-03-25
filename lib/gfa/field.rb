class GFA::Field
   # Class-level
   CODES = {
      :A => :Char,
      :i => :SigInt,
      :f => :Float,
      :Z => :String,
      :H => :Hex,
      :B => :NumArray
   }
   TYPES = CODES.values
   
   # Instance-level
   attr :value

   def type ; CODES[code] ; end
   
   def code ; self.class::CODE ; end
   
   def regex ; self.class::REGEX ; end
   
   def to_s(with_type=true)
      "#{"#{code}:" if with_type}#{value}"
   end
   
   def hash
      value.hash
   end

   # Load types
   TYPES.each do |t|
      require "gfa/field/#{t.downcase}"
   end

end
