
##
# A class to represent sparse matrices internally used for graph operations
class GFA::Matrix

  attr_accessor :rows, :columns, :values

  ##
  # Initialize a Matrix with +rows+ and +columns+ (both should be Integer),
  # and a default +value+ (+nil+ if missing)
  def initialize(rows, columns, value = nil)
    raise 'Matrix rows must be an integer' unless rows.is_a? Integer
    raise 'Matrix columns must be an integer' unless columns.is_a? Integer
    raise 'Matrix rows must be positive' if rows < 0
    raise 'Matrix columns must be positive' if columns < 0

    @rows    = rows
    @columns = columns
    @values  = Hash.new(value)
  end

  def [](row = nil, col = nil)
    index(row, col).map { |i| values[i] }
  end

  def []=(row, col, value)
    values = (row.nil? || col.nil?) ? value : [value]
    unless values.is_a? Array
      raise 'Value must be an array if setting a range of cells'
    end

    idx = index(row, col)
    if idx.size != values.size
      raise "Expected #{idx.size} values, but only got #{values.size}"
    end
    idx.each_with_index.map { |i, k| @values[i] = values[k] }
  end

  ##
  # Determines the index of +row+ and +col+ (both must be defined Integer),
  # sets its value to an empty Array if not yet defined, and appends +value+.
  # Returns an error if the value already exists but it's not an array
  def append(row, col, value)
    raise 'wow must be a defined integer' unless row.is_a?(Integer)
    raise 'col must be a defined integer' unless col.is_a?(Integer)

    idx = index(row, col).first
    @values[idx] ||= []
    unless @values[idx].is_a? Array
      raise 'The values exists and it is not an array'
    end

    @values[idx] << value
  end

  ##
  # Returns the list of indexes determined by +row+ and +col+ as an Array:
  # - If +row+ and +col+ are Integer, it returns the value at the given cell
  # - If both +row+ and +col+ are +nil+, it returns the indexes for all values
  # - If +row+ xor +col+ are +nil+, it returns the indexes of the entire column
  #   or row, respectively.
  def index(row = nil, col = nil)
    if row.nil? && col.nil?
      # All values
      (0 .. values.size - 1).to_a
    elsif row.nil?
      # Entire column
      (col_offset(col) .. col_offset(col) + rows - 1).to_a
    elsif col.nil?
      # Entire row
      ric = row_in_column(row)
      (0 .. columns - 1).map { |i| col_offset(i) + ric }
    else
      # Single value
      [col_offset(col) + row_in_column(row)]
    end
  end

  ##
  # Index of the first cell of the +col+. The column is a 0-based
  # index, with negative integers representing columns counted from
  # the bottom (-1 being the last column)
  def col_offset(col)
    col = cols + col if col < 0
    col * rows
  end

  ##
  # Index of the +row+ as if it was in the first column. The row
  # is a 0-based index, with negative integers representing rows
  # counted from the end (-1 being the last row)
  def row_in_column(row)
    row = rows + row if row < 0
    row
  end
end
