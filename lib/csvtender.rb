class CSVtender
  def initialize(table = [])
    @table = table
    @orientation = :standard
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

  def map(mutator = nil)
    delegate :map!, mutator
  end

  def select(mutator = nil)
    delegate :select!, mutator
  end

  def reject(mutator = nil)
    delegate :reject!, mutator
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

  def delegate(method, mutator = nil)
    raise ArgumentError, 'must provide mutator or block' unless block_given? || mutator
    block ||= -> (item) { mutator.call item }
    oriented { @table.send(method, &block) }
    self
  end
end