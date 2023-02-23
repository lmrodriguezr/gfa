require 'gfa/record'

class GFA
  # Class-level
  MIN_VERSION = '1.0'
  MAX_VERSION = '1.2'

  ##
  # Load a GFA object from a +gfa+ file with options +opts+:
  # - index: If the records should be indexed as loaded (default: true)
  # - comments: If the comment records should be saved (default: false)
  def self.load(file, opts = {})
    gfa = GFA.new(opts)
    fh = File.open(file, 'r')
    fh.each { |ln| gfa << ln }
    gfa
  ensure
    fh&.close
  end

  def self.supported_version?(v)
    v.to_f >= MIN_VERSION.to_f and v.to_f <= MAX_VERSION.to_f
  end

  # Instance-level
  def <<(obj)
    obj = parse_line(obj) unless obj.is_a? GFA::Record
    return if obj.nil? || obj.empty?
    @records[obj.type] << obj

    if obj.type == :Header && !obj.VN.nil?
      set_gfa_version(obj.VN.value)
    end
  end

  def set_gfa_version(v)
    v = v.value if v.is_a? GFA::Field
    unless GFA::supported_version? v
      raise "GFA version currently unsupported: #{v}"
    end

    @gfa_version = v
  end

  private

    def parse_line(string)
      string = string.chomp
      return nil if string =~ /^\s*$/
      return nil if !opts[:comments] && string[0] == '#'

      GFA::Record[string]
    end
end
