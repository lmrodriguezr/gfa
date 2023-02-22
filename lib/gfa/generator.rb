class GFA
  def save(file)
    fh = File.open(file, 'w')
    each_line do |ln|
      fh.puts ln
    end
    fh.close
  end

  def each_line(&blk)
    set_version_header('1.1') if gfa_version.nil?
    GFA::Record.TYPES.each do |r_type|
      records[r_type].each do |record|
        blk[record.to_s]
      end
    end
  end

  def set_version_header(v)
    unset_version
    @records[:Header] << GFA::Record::Header.new("VN:Z:#{v}")
    @gfa_version = v
  end

  def unset_version
    @records[:Header].delete_if { |o| !o.fields[:VN].nil? }
    @gfa_version = nil
  end

  def to_s
    o = ''
    each_line { |ln| o += ln + "\n" }
    o
  end
end
