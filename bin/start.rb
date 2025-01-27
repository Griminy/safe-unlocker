#!/usr/bin/env ruby

require_relative '../app/services/unlock_steps_builder'

def format_point(point, levers_count, with_raise: true)
	point.gsub(/\s/, '').split(',').map(&:to_i).tap do |res|
		return res unless with_raise

		invalid_value = res.find { |i| i < 0 || i > 9 }
		raise "Point #{res} is invalid." if invalid_value || res.count != levers_count
	end
end

puts "\nEnter count of safe levers. Possible values are 3-6:"

levers_count = [gets.to_i, 3].max
raise 'Invalid levers count' if levers_count > 6 || levers_count < 3

valid_format_of_point = Proc.new { |i| ([i.to_i] * levers_count).join(',') }

puts "Enter start point. Valid format is #{valid_format_of_point.call}:"

start_point = format_point(gets, levers_count, with_raise: false)
start_point = [0, 0, 0] if start_point.empty?

puts "\nEnter target_point point. Valid format still is #{valid_format_of_point.call(1)}:"

target_point = format_point(gets, levers_count)
raise 'target variable must be valid' if target_point.nil? || target_point.empty?

puts "\nEnter restricted points."
puts "Valid format is #{valid_format_of_point.call(2)};#{valid_format_of_point.call(3)}."
puts "Where ',' is for point separator and ';' is points separator:"

restricted_points = gets.gsub(/\s/, '').split(';').map { |p| format_point(p, levers_count) }

puts "\nSo your variables are:"
puts "levers_count = #{levers_count}"
puts "start_point = #{start_point}"
puts "target_point = #{target_point}"
puts "restricted_points = #{restricted_points}"

service = UnlockStepsBuilder.new(
	levers_count: levers_count,
	start_point: start_point,
	target_point: target_point,
	restricted_points: restricted_points
)
service.call { |_step| print '.' }

puts "\nResult:"
result = service.visited_points.map(&:inspect)
puts result.empty? ? 'There is no solution for this' : result