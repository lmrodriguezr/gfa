class GFA::Record
  # Class-level
  CODES = {
    :'#' => :Comment,
    H: :Header,
    S: :Segment,
    L: :Link,
    J: :Jump, # Since 1.2
    C: :Containment,
    P: :Path,
    W: :Walk # Since 1.1
  }
  REQ_FIELDS = []
  OPT_FIELDS = {}
  TYPES = CODES.values
  TYPES.each { |t| require "gfa/record/#{t.downcase}" }

  %i[CODES REQ_FIELDS OPT_FIELDS TYPES].each do |x|
    define_singleton_method(x) { const_get(x) }
  end

  def self.code_class(code)
    name = CODES[code.to_sym]
    raise "Unknown record type: #{code}." if name.nil?
    name_class(name)
  end

  def self.name_class(name)
    const_get(name)
  end

  def self.[](string)
    return nil if string.nil? || string =~ /^\s*$/

    split = string[0] == '#' ? ['', 2] : ["\t", 0]
    code, *values = string.chomp.split(*split)
    code_class(code).new(*values)
  end

  # Instance-level

  attr :fields

  def [](k)
    fields[k]
  end

  def type
    CODES[code]
  end

  def code
    self.class.const_get(:CODE)
  end

  def empty?
    fields.empty?
  end

  def to_s
    o = [code.to_s]
    self.class.REQ_FIELDS.each_index do |i|
      o << fields[i + 2].to_s(false)
    end
    fields.each do |k, v|
      next if k.is_a? Integer
      o << "#{k}:#{v}"
    end
    o.join("\t")
  end

  def dup
    self.class[to_s]
  end

  def hash
    { code => fields }.hash
  end

  def eql?(rec)
    hash == rec.hash
  end

  alias == eql?

  private

    def add_field(f_tag, f_type, f_value, format = nil)
      unless format.nil?
        msg = (f_tag.is_a?(Integer) ? "column #{f_tag}" : "#{f_tag} field")
        GFA.assert_format(f_value, format, "Bad #{type} #{msg}")
      end

      @fields[f_tag] = GFA::Field.code_class(f_type).new(f_value)
    end

    def add_opt_field(f, known)
      m = /^([A-Za-z]+):([A-Za-z]+):(.*)$/.match(f)
      raise "Cannot parse field: '#{f}'" unless m

      f_tag = m[1].to_sym
      f_type = m[2].to_sym
      f_value = m[3]

      if known[f_tag].nil? && f_tag =~ /^[A-Z]+$/
        raise "Unknown reserved tag #{f_tag} for a #{type} record."
      end

      unless known[f_tag].nil? || known[f_tag] == f_type
        raise "Wrong field type #{f_type} for a #{f_tag} tag," \
          " expected #{known[f_tag]}"
      end

      add_field(f_tag, f_type, f_value)
    end
end
