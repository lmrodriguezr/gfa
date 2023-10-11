require 'gfa/version'
require 'gfa/matrix'
require 'gfa/record_set'
require 'gfa/field'

class GFA
  # Class-level
  def self.assert_format(value, regex, message)
    unless value =~ /^(?:#{regex})$/
      raise "#{message}: #{value}"
    end
  end

  def self.advance_bar(n)
    @advance_bar_n = n
    @advance_bar_i = 0
    @advance_bar_p = 0
    @advance_bar_s = Time.now
    $stderr.print '  [' + (' ' * 50) + ']' + " #{n}\r"
    $stderr.print '  [>'
  end

  def self.advance
    @advance_bar_i += 1
    # $stderr.print "#{@advance_bar_i}"[-1] + "\b"
    while 50 * @advance_bar_i / @advance_bar_n > @advance_bar_p
      $stderr.print "\b=>"
      @advance_bar_p += 1
    end
    return unless @advance_bar_i == @advance_bar_n

    $stderr.print "\b]\r"
    t_t = Time.now - @advance_bar_s
    t_u = 'sec'

    if t_t > 60
      t_t /= 60
      t_u = 'min'
    end

    if t_t > 60
      t_t /= 60
      t_u = 'h'
    end

    $stderr.puts '  [ %-48s ]' % "Time elapsed: #{'%.1f' % t_t} #{t_u}"
  end

  # Instance-level
  attr :gfa_version, :records, :opts

  GFA::Record.TYPES.each do |r_type|
    singular = "#{r_type.downcase}"
    plural = "#{singular}s"

    define_method(plural) { records[r_type] }
    define_method(singular) { |k| records[r_type][k] }
    define_method("add_#{singular}") { |v| @records[r_type] << v }
  end

  def initialize(opts = {})
    @records = {}
    @opts = { index: true, index_id: false, comments: false }.merge(opts)
    GFA::Record.TYPES.each do |t|
      @records[t] = GFA::RecordSet.name_class(t).new(self)
    end
  end

  def empty?
    records.empty? || records.values.all?(&:empty?)
  end

  def eql?(gfa)
    records == gfa.records
  end

  def ==(gfa)
    eql?(gfa)
  end

  def size
    records.values.map(&:size).inject(0, :+)
  end

  def merge!(gfa)
    raise "Unsupported object: #{gfa}" unless gfa.is_a? GFA

    GFA::Record.TYPES.each do |t|
      @records[t].merge!(gfa.records[t])
    end
  end

  def indexed?
    records.values.all?(&:indexed?)
  end

  def rebuild_index!
    @records.each_value(&:rebuild_index!)
  end

  ##
  # Computes the sum of all individual segment lengths
  def total_length
    segments.total_length
  end

  ##
  # Adds the entrie of +gfa+ to itself
  def merge!(gfa)
    records.each { |k, v| v.merge!(gfa.records[k]) }
    self
  end

  ##
  # Creates a new GFA based on itself and appends all entries in +gfa+
  def merge(gfa)
    GFA.new(opts).merge!(self).merge!(gfa)
  end
end
