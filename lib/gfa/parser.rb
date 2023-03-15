require 'gfa/record'

class GFA
  # Class-level
  MIN_VERSION = '1.0'
  MAX_VERSION = '1.2'

  ##
  # Load a GFA object from a gfa +file+ with options +opts+:
  # - index: If the  records should be indexed as loaded (default: true)
  # - index_id: If the records should also be index by ID (default: false)
  # - comments: If the comment records should be saved (default: false)
  # - line_range: Two-integer array indicating the first and last lines to read
  #   (default: nil, read the entire file)
  def self.load(file, opts = {})
    gfa = GFA.new(opts)
    read_records(file, opts) do |record|
      gfa << record
    end
    gfa
  end

  def self.read_records(file, opts = {})
    rng = opts[:line_range]
    File.open(file, 'r') do |fh|
      lno = -1
      fh.each do |ln|
        lno += 1
        next if !rng.nil? && (lno < rng[0] || lno > rng[1])
        next if !opts[:comments] && ln[0] == '#'

        yield(GFA::Record[ln])
      end
    end
  end

  ##
  # Load a GFA object from a gfa +file+ in parallel using +thr+ threads,
  # and the same +opts+ supported by +load+. Defaults to the +load+ method
  # instead if +thr <= 1+.
  def self.load_parallel(file, thr, opts = {})
    return self.load(file, opts) if thr <= 1

    # Prepare data
    lno = 0
    File.open(file, 'r') { |fh| fh.each { lno += 1 } }
    thr = lno if thr > lno
    blk = (lno.to_f / thr).ceil

    # Launch children processes
    io  = []
    pid = []
    thr.times do |i|
      io[i] = IO.pipe
      pid << fork do
        io[i][0].close
        o = opts.merge(line_range: [i * blk, (i + 1) * blk - 1])
        records = []
        read_records(file, o) { |record| records << record }
        Marshal.dump(records, io[i][1])
        exit!(0)
      end
      io[i][1].close
    end

    # Collect and merge results
    gfa = GFA.new(opts)
    io.each_with_index do |pipe, k|
      result = pipe[0].read
      Process.wait(pid[k])
      raise "Child process failed: #{k}" if result.empty?
      Marshal.load(result).each { |record| gfa << record }
      pipe[0].close
    end

    return gfa
  end

  def self.supported_version?(v)
    v.to_f >= MIN_VERSION.to_f and v.to_f <= MAX_VERSION.to_f
  end

  # Instance-level
  def <<(obj)
    obj = GFA::Record[obj] unless obj.is_a? GFA::Record
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
end
