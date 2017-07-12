require_relative '../lib/csvtender'

describe CSVtender do
  subject { CSVtender.new table }

  let(:table) do
    [[1, 2, 3],
     [4, 5, 6]]
  end

  let(:x2) { -> (set) { set.map { |cell| cell * 2 } } }
  let(:small_sum) { -> (set) { set.inject(:+) < 8 } }

  describe '#show' do
    it 'shows rows' do
      expect(subject.rows.show).to eql table
    end

    it 'shows columns' do
      expect(subject.cols.show).to eql [[1, 4],
                                        [2, 5],
                                        [3, 6]]
    end
  end

  describe '#count' do
    it 'counts rows' do
      expect(subject.rows.count).to be 2
    end

    it 'counts columns' do
      expect(subject.cols.count).to be 3
    end
  end

  describe '#map' do
    it 'maps over rows' do
      expect(subject.rows.map(x2).show).to eql [[2, 4, 6],
                                                [8, 10, 12]]
    end

    it 'maps over columns' do
      expect(subject.cols.map(x2).show).to eql [[2, 8],
                                                [4, 10],
                                                [6, 12]]
    end
  end

  describe '#select' do
    it 'maps over rows' do
      expect(subject.rows.select(small_sum).show).to eql [[1, 2, 3]]
    end

    it 'maps over columns' do
      expect(subject.cols.select(small_sum).show).to eql [[1, 4],
                                                          [2, 5]]
    end
  end

  describe '#reject' do
    it 'maps over rows' do
      expect(subject.rows.reject(small_sum).show).to eql [[4, 5, 6]]
    end

    it 'maps over columns' do
      expect(subject.cols.reject(small_sum).show).to eql [[3, 6]]
    end
  end
end
