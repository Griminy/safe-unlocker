require 'spec_helper'
require 'timeout'

RSpec.describe UnlockStepsBuilder do
	describe '#call' do
		subject(:unlocker) do
			described_class.new(
				start_point: start_point,
				levers_count: levers_count,
				target_point: target_point,
				restricted_points: restricted_points
			)
		end

		let(:restricted_points) { nil }
		let(:start_point) { [0, 0, 0] }
		let(:levers_count) { 3 }

		shared_examples 'when visited points as expected' do
			it 'completes within timeout' do
				Timeout.timeout(2) do
					unlocker.call
					expect(unlocker.visited_points).to eq(expected_points)
				end
			end
		end

		describe 'possible cases' do
			context 'when solution is in one step' do
				let(:target_point) { [0, 0, 1] }
				let(:expected_points) { [[0, 0, 1]] }

				it_behaves_like 'when visited points as expected'
			end

			context 'when solution requires multiple steps' do
				let(:target_point) { [1, 1, 1] }
				let(:expected_points) { [[1, 0, 0], [1, 1, 0], [1, 1, 1]] }

				it_behaves_like 'when visited points as expected'
			end

			context 'when target equals start point' do
				let(:target_point) { [0, 0, 0] }
				let(:expected_points) { [	] }

				it_behaves_like 'when visited points as expected'
			end

			context 'with restricted points' do
				let(:target_point) { [1, 1, 1] }
				let(:restricted_points) { [[1, 0, 0]] }
				let(:expected_points) { [[0, 1, 0], [0, 1, 1], [1, 1, 1]] }

				it_behaves_like 'when visited points as expected'
			end

			context 'when target is unreachable' do
				let(:target_point) { [1, 1, 1] }
				let(:restricted_points) { [[1, 0, 0], [0, 1, 0], [0, 0, 1]] }
				let(:expected_points) { [] }

				it_behaves_like 'when visited points as expected'
			end
		end

		describe 'edge cases' do
			context 'with maximum lever count' do
				let(:levers_count) { 6 }
				let(:start_point) { [0, 0, 0, 0, 0, 0] }
				let(:target_point) { [1, 1, 1, 1, 1, 1] }
				let(:expected_points) do
					[
						[1, 0, 0, 0, 0, 0],
						[1, 1, 0, 0, 0, 0],
						[1, 1, 1, 0, 0, 0],
						[1, 1, 1, 1, 0, 0],
						[1, 1, 1, 1, 1, 0],
						[1, 1, 1, 1, 1, 1]
					]
				end

				it_behaves_like 'when visited points as expected'
			end

			context 'with maximum values' do
				let(:target_point) { [9, 9, 9] }
				
				before { unlocker.call }

				it 'reaches target point' do
					expect(unlocker.visited_points.last).to eq(target_point)
				end
			end

			context 'with almost locked way to target (variant 1)' do
				let(:target_point) { [9, 9, 9] }
				let(:restricted_points) { [[9, 9, 8], [9, 8, 9]] }
				let(:expected_points) do
					[
						[1, 0, 0],
						[1, 1, 0],
						[1, 1, 1],
						[2, 1, 1],
						[2, 2, 1],
						[2, 2, 2],
						[3, 2, 2],
						[3, 3, 2],
						[3, 3, 3],
						[4, 3, 3],
						[4, 4, 3],
						[4, 4, 4],
						[5, 4, 4],
						[5, 5, 4],
						[5, 5, 5],
						[6, 5, 5],
						[6, 6, 5],
						[6, 6, 6],
						[7, 6, 6],
						[7, 7, 6],
						[7, 7, 7],
						[8, 7, 7],
						[8, 8, 7],
						[8, 8, 8],
						[8, 9, 8],
						[8, 9, 9],
						[9, 9, 9]
					]
				end

				it_behaves_like 'when visited points as expected'
			end

			context 'with almost locked way to target (variant 2)' do
				let(:target_point) { [9, 9, 9] }
				let(:restricted_points) { [[8, 9, 9], [9, 8, 9]] }
				let(:expected_points) do
					[
						[1, 0, 0],
						[1, 1, 0],
						[1, 1, 1],
						[2, 1, 1],
						[2, 2, 1],
						[2, 2, 2],
						[3, 2, 2],
						[3, 3, 2],
						[3, 3, 3],
						[4, 3, 3],
						[4, 4, 3],
						[4, 4, 4],
						[5, 4, 4],
						[5, 5, 4],
						[5, 5, 5],
						[6, 5, 5],
						[6, 6, 5],
						[6, 6, 6],
						[7, 6, 6],
						[7, 7, 6],
						[7, 7, 7],
						[8, 7, 7],
						[8, 8, 7],
						[8, 8, 8],
						[9, 8, 8],
						[9, 9, 8],
						[9, 9, 9]
					]
				end

				it_behaves_like 'when visited points as expected'
			end

			context 'with almost locked way to target (variant 3)' do
				let(:target_point) { [9, 9, 9] }
				let(:restricted_points) { [[8, 8, 9], [9, 9, 8]] }
				let(:expected_points) do
					[
						[1, 0, 0],
						[1, 1, 0],
						[1, 1, 1],
						[2, 1, 1],
						[2, 2, 1],
						[2, 2, 2],
						[3, 2, 2],
						[3, 3, 2],
						[3, 3, 3],
						[4, 3, 3],
						[4, 4, 3],
						[4, 4, 4],
						[5, 4, 4],
						[5, 5, 4],
						[5, 5, 5],
						[6, 5, 5],
						[6, 6, 5],
						[6, 6, 6],
						[7, 6, 6],
						[7, 7, 6],
						[7, 7, 7],
						[8, 7, 7],
						[8, 8, 7],
						[8, 8, 8],
						[9, 8, 8],
						[9, 8, 9],
						[9, 9, 9]
					]
				end
				
				it_behaves_like 'when visited points as expected'
			end
		end

		describe 'with block given' do
			let(:target_point) { [1, 1, 1] }

			it 'yields for each step' do
				count = 0
				Timeout.timeout(2) do
					unlocker.call { count += 1 }
					expect(count).to eq 3
				end
			end
		end
	end
end
