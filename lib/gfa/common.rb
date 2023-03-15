require 'gfa/version'
require 'gfa/record_set'
require 'gfa/field'

class GFA
  # Class-level
  def self.assert_format(value, regex, message)
    unless value =~ /^(?:#{regex})$/
      raise "#{message}: #{value}"
    end
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
end
