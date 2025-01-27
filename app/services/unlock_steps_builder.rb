class UnlockStepsBuilder
	class ExtraStepsCounterError < StandardError; end
	class InvalidStepsError < StandardError; end

	attr_reader :start_point, :levers_count, :target_point,
							:restricted_points, :variants, :steps,
							:current_point, :visited_points, :extra_points,
							:max_extra_steps_count, :pending_extra_indexes

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
		@max_extra_steps_count = 10 * levers_count
		@pending_extra_indexes = steps.to_enum
	end

	def call
		validate_income_params

		pending_indexes = steps.to_a
		mem_points = nil
		last_matched_step = nil

		while !pending_indexes.size.zero?
			begin
				step = steps.next
				
				yield if block_given?

				if roll_the_lever(step, with_extra: extra_steps_counter_exceeded?(10))
					last_matched_step = step
					pending_indexes -= [last_matched_step]

					return true if completed?
				end

				unless extra_points.empty?
					pending_indexes = (pending_indexes + [extra_points.shift]).uniq 
				end
			rescue StopIteration
				steps.rewind

				if memorized_points_frozen?
					extra_index = next_extra_index
					extra_points[extra_index] << extra_index if roll_the_lever(extra_index, with_extra: true)
					extra_steps_counter_increment
					remove_last_point_as_invalid(pending_indexes, last_matched_step)
				else
					extra_points_reset
					memorize_points
				end

				extra_steps_counter_check
			end
		end
	rescue ExtraStepsCounterError, InvalidStepsError
		@visited_points = []
	end

	private

	def validate_income_params
		return if target_point != start_point && (!restricted_points || !restricted_points.include?(target_point))

		raise InvalidStepsError
	end

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

	def extra_steps_counter_exceeded?(count = @max_extra_steps_count)
		@extra_steps_counter && @extra_steps_counter >= count
	end

	def extra_steps_counter_increment
		@extra_steps_counter ||= 0
		@extra_steps_counter += 1
	end

	def extra_points_reset
		@extra_steps_counter = 0 if @last_invalid_point.nil?
		@last_invalid_point = nil
	end

	def extra_steps_counter_check
		return true if !@extra_steps_counter || @extra_steps_counter <= @max_extra_steps_count

		raise ExtraStepsCounterError
	end

	def roll_the_lever(lever_index, with_extra: false)
		return false if lever_match?(lever_index) && !with_extra

		mem = current_point[lever_index].dup

		if mem && (mem + 1 <= target_point[lever_index] || with_extra)
			return false unless incement(lever_index)
		elsif mem && mem > target_point[lever_index]
			return false unless decrement(lever_index)
		end

		if restricted_step?(current_point) || visited_points.include?(current_point) || last_point_frozen?
			current_point[lever_index] = mem
			return false
		else
			visited_points << current_point.dup
			
			return lever_match?(lever_index)
		end

		false
	end

	def remove_last_point_as_invalid(pending_indexes, last_matched_step)
		@last_invalid_point = @visited_points.pop
		@current_point = @visited_points.last.dup || []
		pending_indexes.push(last_matched_step) unless pending_indexes.include?(last_matched_step)
		memorize_points
	end

	def memorize_points
		@memorized_points = visited_points.dup
	end

	def memorized_points_frozen?
		@memorized_points == visited_points
	end

	def last_point_frozen?
		@last_invalid_point && @last_invalid_point == current_point
	end

	def completed?
		visited_points.include?(target_point)
	end

	def next_extra_index
		pending_extra_indexes.next
	rescue StopIteration
		pending_extra_indexes.rewind.next
	end
end