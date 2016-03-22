require "gfa/record"

class GFA
   # Class-level
   MIN_VERSION = "1.0"
   MAX_VERSION = "1.0"
   def self.load(file)
      gfa = GFA.new
      fh = File.open(file, "r")
      fh.each { |ln| gfa << ln }
      fh.close
      gfa
   end
   def self.supported_version?(v)
      ver = []
      ver << MIN_VERSION.split("\.").map{ |x| x.to_i }
      ver << MAX_VERSION.split("\.").map{ |x| x.to_i }
      ver << v.split("\.").map{ |x| x.to_i }
      ver.map! do |v|
	 (v[0]*100 + v[1])*100 + (v[2] || 0)
      end
      ver[2] >= ver[0] and ver[2] <= ver[1]
   end

   # Instance-level
   def <<(obj)
      obj = parse_line(obj) unless obj.is_a? GFA::Record
      return if obj.nil? or obj.empty?
      @records[obj.type] << obj
      if obj.type==:Header and not obj.fields[:VN].nil?
	 set_gfa_version(obj.fields[:VN].value)
      end
   end

   def set_gfa_version(v)
      @gfa_version = v
      raise "GFA version currently unsupported: #{v}." unless
	 GFA::supported_version? gfa_version
   end
   
   private
      def parse_line(ln)
	 ln.chomp!
	 return nil if ln =~ /^\s*$/
	 cols = ln.split("\t")
	 type = Record::CODES[cols.shift.to_sym]
	 Object.const_get("GFA::Record::#{type}").new(*cols)
      end
end
