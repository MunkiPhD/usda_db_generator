require 'abbreviated_parser'

describe AbbreviatedParser do
	let(:baked_beans) { "~16200~^~CAMPBELL'S BRN SUGAR&BACON FLAV BKD BNS~^69.40^123^3.85^1.92^1.75^23.08^6.2^10.00^31^1.11^^^^362^^^^^0.0^^^^^^^^^^^^0^^^^^^^^^^^^0.385^^^4^130^~.5 cup~^130^~1 serving~^0" }

	describe '.parse' do
		subject { AbbreviatedParser.parse(baked_beans) }

		it 'has correct ndb_id' do
			expect(subject[:ndb_id]).to eq 16200
		end

		it 'has correct calories' do
			expect(subject[:calories]).to eq 160
		end

		it 'has correct total fat' do
			expect(subject[:total_fat]).to eq 2.5
		end

		it 'has correct saturated fat' do
			expect(subject[:saturated_fat]).to eq 1
		end

		it 'has correct polyunsaturated fat' do
			expect(subject[:polyunsaturated_fat]).to eq 0
		end

		it 'has correct monounsaturated fat' do
			expect(subject[:monounsaturated_fat]).to eq 0
		end

		it 'has correct cholesterol' do
			expect(subject[:cholesterol]).to eq 3
		end

		it 'has correct sodium' do
			expect(subject[:sodium]).to eq 471
		end

		it 'has correct potassium' do
			expect(subject[:potassium]).to eq 0
		end

		it 'has correct total carbs' do
			expect(subject[:total_carbs]).to eq 30
		end

		it 'has correct dietary fiber' do
			expect(subject[:dietary_fiber]).to eq 8
		end

		it 'has correct dietary fiber' do
			expect(subject[:sugars]).to eq 8
		end

		it 'has correct protein' do
			expect(subject[:protein]).to eq 5
		end

		it 'has correct calcium' do
			expect(subject[:calcium]).to eq 40
		end

		it 'has correct iron' do
			expect(subject[:iron]).to eq 1 
		end
	end
end
