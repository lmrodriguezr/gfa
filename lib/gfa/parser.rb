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
    v.to_f >= MIN_VERSION.to_f and v.to_f <= MAX_VERSION.to_f
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
      GFA::Record.code_class(cols.shift).new(*cols)
    end

end
