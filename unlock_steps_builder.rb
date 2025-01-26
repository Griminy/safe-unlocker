class UnlockStepsBuilder
	attr_reader :start_point, :levers_count, :target_point, :restricted_points, :variants, :steps,
							:current_point, :visited_points, :extra_points

	def initialize(start_point:, levers_count:, target_point:, restricted_points: nil)
		@start_point = start_point
		@levers_count = levers_count
		@target_point = target_point
		@restricted_points = restricted_points
		@variants = (0..9).to_a
		@steps = (0..levers_count - 1).to_enum
		@current_point = start_point.dup
		@visited_points = []
		@extra_points = []
	end

	def call
		pending_indexes = steps.to_a
		pending_extra_indexes = pending_indexes.to_enum
		mem_points = nil
		while !pending_indexes.size.zero?
			begin
				step = steps.next
				pending_indexes -= [step] if roll_the_lever(step)
				pending_indexes << extra_points.shift unless extra_points.empty?
			rescue StopIteration
				steps.rewind

				if mem_points == visited_points
					extra_index = next_extra_index(pending_extra_indexes)
					extra_points[extra_index] << extra_index if roll_the_lever(extra_index, with_extra: true)
				else
					mem_points = visited_points.dup
				end
			end
		end
	end

	private

	def restricted_step?(point)
		restricted_points && restricted_points.include?(point)
	end

	def lever_match?(lever_index)
		current_point[lever_index] == target_point[lever_index]
	end

	def incement(lever_index)
		next_step = current_point[lever_index] + 1
		return false unless variants.include?(next_step)

		current_point[lever_index] = next_step
	end

	def decrement(lever_index)
		next_step = current_point[lever_index] - 1
		return false unless variants.include?(next_step)

		current_point[lever_index] = next_step
	end

	def roll_the_lever(lever_index, with_extra: false)
		return false if lever_match?(lever_index) && !with_extra

		mem = current_point[lever_index]

		if mem + 1 <= target_point[lever_index] || with_extra
			return false unless incement(lever_index)
		elsif mem > target_point[lever_index]
			return false unless decrement(lever_index)
		end

		if restricted_step?(current_point) || visited_points.include?(current_point)
			current_point[lever_index] = mem
			return false
		else
			visited_points << current_point.dup
			
			return lever_match?(lever_index)
		end

		false
	end

	def next_extra_index(pending_indexes)
		pending_indexes.next rescue pending_indexes.rewind.next
	end
end