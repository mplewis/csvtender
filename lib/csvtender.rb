class CSVtender
  # Creates a new CSVtender.
  # @param table [Array] Optional: initial data for the table
  def initialize(table = [])
    @table = table
    @orientation = :standard
    @headers = false
  end

  def to_s
    s = @table.count != 1 ? 's' : ''
    meta = [
      "#{@table.count} row#{s}",
      @headers ? 'headers' : nil
    ].compact.join ', '
    "\#<CSVtender: #{meta}>"
  end

  def inspect
    @table
  end

  # Orients the table traditionally - table contains rows which contain cells.
  def rows
    @orientation = :standard
    self
  end

  # Orients the table transposed - table contains columns which contain cells.
  def cols
    @orientation = :vertical
    self
  end

  # Outputs the table as an array of rows.
  def show
    table = nil
    oriented { table = @table }
    table
  end

  # The number of rows this table contains.
  def count
    show.count
  end

  # Maps each row or column in this table over a user-provided function.
  def map(mutator = nil, &block)
    delegate :map!, mutator, &block
  end

  # Calls the user-provided function and includes only items for which the function returns truthy.
  def select(mutator = nil, &block)
    delegate :select!, mutator, &block
  end

  # Calls the user-provided function and rejects items for which the function returns truthy.
  def reject(mutator = nil, &block)
    delegate :reject!, mutator, &block
  end

  # Treat this table as if the first row is a header row.
  def with_headers
    return self if @headers
    oriented do
      @headers = true
      header, *rows = @table
      @table = rows.map! { |row| header.zip(row).to_h }
    end
    self
  end

  # Treat this table as if it has no header row.
  def without_headers
    return self unless @headers
    @headers = false
    header = @table.first.keys
    without_keys = @table.map(&:values)
    @table = [header].concat without_keys
    self
  end

  private

  def vertical?
    @orientation == :vertical
  end

  # Helper method. Pass it a block and it will always call the block with the table in standard orientation.
  def oriented
    transpose if vertical?
    yield
    transpose if vertical?
  end

  # Transposes the table data between row and column orientation. Calling this twice in a row is a no-op.
  def transpose
    head, *tail = @table
    @table = head.zip(*tail)
  end

  # Helper method. Handles both styles of user-provided block.
  def delegate(method, mutator = nil, &block)
    raise ArgumentError, 'must provide mutator or block' unless block_given? || mutator
    block ||= -> (item) { mutator.call item }
    oriented { @table.send(method, &block) }
    self
  end
end
