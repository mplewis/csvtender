class CSVtender
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

  def rows
    @orientation = :standard
    self
  end

  def cols
    @orientation = :vertical
    self
  end

  def show
    table = nil
    oriented { table = @table }
    table
  end

  def count
    show.count
  end

  def map(mutator = nil, &block)
    delegate :map!, mutator, &block
  end

  def select(mutator = nil, &block)
    delegate :select!, mutator, &block
  end

  def reject(mutator = nil, &block)
    delegate :reject!, mutator, &block
  end

  def with_headers
    return if @headers
    oriented do
      @headers = true
      header, *rows = @table
      @table = rows.map! { |row| header.zip(row).to_h }
    end
    self
  end

  def without_headers
    return unless @headers
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

  def oriented
    transpose if vertical?
    yield
    transpose if vertical?
  end

  def transpose
    head, *tail = @table
    @table = head.zip(*tail)
  end

  def delegate(method, mutator = nil, &block)
    raise ArgumentError, 'must provide mutator or block' unless block_given? || mutator
    block ||= -> (item) { mutator.call item }
    oriented { @table.send(method, &block) }
    self
  end
end
