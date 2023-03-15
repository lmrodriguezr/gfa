
require 'gfa/record'

class GFA::RecordSet
  INDEX_FIELD = nil
  TYPES = GFA::Record.TYPES.map { |i| :"#{i}Set" }
  GFA::Record.TYPES.each { |t| require "gfa/record_set/#{t.downcase}_set" }

  %i[TYPES].each do |x|
    define_singleton_method(x) { const_get(x) }
  end

  def self.code_class(code)
    name = GFA::Record.CODES[code.to_sym]
    raise "Unknown record type: #{code}." if name.nil?
    name_class(name)
  end

  def self.name_class(name)
    name = "#{name}Set" unless name =~ /Set$/
    const_get(name)
  end

  # Instance-level

  attr_reader :set, :index, :gfa

  def initialize(gfa = nil)
    @set   = []
    @index = {}
    @gfa   = gfa || GFA.new
  end

  def [](k)
    return set[k] if k.is_a?(Integer)
    find_index(k)
  end

  def type
    GFA::Record.CODES[code]
  end

  def code
    self.class.const_get(:CODE)
  end

  def index_field
    self.class.const_get(:INDEX_FIELD)
  end

  %i[empty? hash size count length first last].each do |i|
    define_method(i) { set.send(i) }
  end

  def to_s
    set.map(&:to_s).join("\n")
  end

  def eql?(rec)
    hash == rec.hash
  end

  alias == eql?

  def <<(v)
    v = v.split("\t") if v.is_a? String
    v = GFA::Record.code_class(code).new(*v) if v.is_a? Array
    raise "Not a GFA Record: #{v}" unless v.is_a? GFA::Record
    raise "Wrong type of record: #{v.type}" if v.type != type

    @set << v
    index!(v)
  end

  def indexed?
    (empty? || !index_field) ? gfa.opts[:index] : !index.empty?
  end

  def rebuild_index!
    @index = {}
    set.each { |v| index!(v) }
  end

  def index_id(v)
    v[index_field]&.value
  end

  def index!(v)
    save_index(index_id(v), v) if index_field

    # Whenever present, index also by ID
    if gfa.opts[:index_id] && v[:ID] && v[:ID].value =~ index_id(v)
      save_index(v[:ID].value, v)
    end
  end

  def save_index(k, v)
    return unless gfa.opts[:index] && k

    if @index[k]
      f = index_field.is_a?(Integer) ? '' : "#{index_field}: "
      raise "#{type} already registered: #{f}#{k}"
    end
    @index[k] = v
  end

  def find_index(k)
    k = k.value if k.is_a? GFA::Field
    @index[k]
  end

  def merge!(record_set)
    raise "Not a record set" unless record_set.is_a?(GFA::RecordSet)
    if record_set.type != type
      raise "Wrong type of record set: #{record_set.type}"
    end

    record_set.set.each { |i| @set << i }
    record_set.index.each { |k, v| save_index(k, v) }
  end
end
