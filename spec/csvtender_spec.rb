require_relative '../lib/csvtender'

describe CSVtender do
  subject { CSVtender.new table }

  let(:table) do
    [[1, 2, 3],
     [4, 5, 6]]
  end

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
    let(:double) { -> (set) { set.map { |cell| cell * 2 } } }

    it 'maps over rows' do
      expect(subject.map(double).show).to eql [[2, 4, 6],
                                               [8, 10, 12]]
    end

    it 'maps over columns' do
      expect(subject.cols.map(double).show).to eql [[2, 8],
                                                    [4, 10],
                                                    [6, 12]]
    end
  end

  context 'filtering' do
    let(:small_sum) { -> (set) { set.inject(:+) < 8 } }

    describe '#select' do
      it 'selects rows' do
        expect(subject.select(small_sum).show).to eql [[1, 2, 3]]
      end

      it 'selects columns' do
        expect(subject.cols.select(small_sum).show).to eql [[1, 4],
                                                            [2, 5]]
      end
    end

    describe '#reject' do
      it 'rejects rows' do
        expect(subject.reject(small_sum).show).to eql [[4, 5, 6]]
      end

      it 'rejects columns' do
        expect(subject.cols.reject(small_sum).show).to eql [[3, 6]]
      end
    end
  end

  context 'with a table with headers' do
    let(:table) do
      [['name', 'loc'],
       ['Matt', 'DEN'],
       ['Anna', 'SFO']]
    end

    let(:in_denver) { -> (row) { row['loc'] == 'DEN' } }

    describe '#with_headers' do
      it 'adds headers' do
        expect(subject.with_headers.show).to eql [{ 'name' => 'Matt', 'loc' => 'DEN' },
                                                  { 'name' => 'Anna', 'loc' => 'SFO' }]
      end

      it 'is chainable' do
        expect(subject.with_headers.select(in_denver).show).to eql [{ 'name' => 'Matt', 'loc' => 'DEN' }]
      end
    end

    describe '#without_headers' do
      it 'reverses #with_headers' do
        expect(subject.rows.with_headers.without_headers.show).to eql table
      end

      it 'is chainable' do
        expect(subject.with_headers.select(in_denver).without_headers.show).to eql [['name', 'loc'],
                                                                                    ['Matt', 'DEN']]
      end
    end
  end

  describe 'private methods' do
    describe '#delegate' do
      it 'works with blocks' do
        subject.send(:delegate, :select!) do |row|
          row.include? 1
        end

        expect(subject.show).to eql [[1, 2, 3]]
      end
    end
  end
end
