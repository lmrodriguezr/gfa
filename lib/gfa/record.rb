require "gfa/field"

class GFA::Record
   # Class-level
   CODES = {
      :H => :Header,
      :S => :Segment,
      :L => :Link,
      :C => :Containment,
      :P => :Path
   }
   REQ_FIELDS = []
   OPT_FIELDS = {}
   TYPES = CODES.values
   
   TYPES.each do |t|
      require "gfa/record/#{t.downcase}"
   end

   # Instance-level
   attr :fields
   
   def type ; CODES[code] ; end
   
   def code ; self.class::CODE ; end
   
   def empty? ; fields.empty? ; end
   
   def to_s
      o = [code.to_s]
      REQ_FIELDS.each_index do |i|
         o << fields[i].to_s(false)
      end
      fields.each do |k,v|
         next if k.is_a? Integer
         o << "#{k}:#{v}"
      end
      o.join("\t")
   end
   
   def hash
      fields.hash
   end

   private
      
      def add_field(f_tag, f_type, f_value, format=nil)
         unless format.nil?
            msg = (f_tag.is_a?(Integer) ? "column #{f_tag}" : "#{f_tag} field")
            GFA::assert_format(f_value, format, "Bad #{type} #{msg}")
         end
         f_type_name = ::GFA::Field::CODES[ f_type ]
         if f_type_name.nil?
            raise "Unknown field type: #{f_type}."
         end
         klass = Object.const_get("GFA::Field::#{f_type_name}")
         @fields[ f_tag ] = klass.new(f_value)
      end
      
      def add_opt_field(f, known)
         m = /^([A-Za-z]+):([A-Za-z]+):(.*)$/.match(f) or
            raise "Cannot parse field: '#{f}'."
         f_tag = m[1].to_sym
         f_type = m[2].to_sym
         f_value = m[3]
         raise "Unknown reserved tag #{f_tag} for a #{type} record." if
            known[f_tag].nil? and f_tag =~ /^[A-Z]+$/
         raise "Wrong field type #{f_type} for a #{f_tag} tag," +
            " expected #{known[f_tag]}" unless
            known[f_tag].nil? or known[f_tag] == f_type
         add_field(f_tag, f_type, f_value)
      end

end
