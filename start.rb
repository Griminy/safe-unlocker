#!/usr/bin/env ruby

require_relative 'unlock_steps_builder'

# START_POINT=ENV['START']&.split(',') || [0, 0, 0]
# LEVERS_COUNT=ENV.fetch('LEVERS_COUNT', 3).to_i
# TARGET_POINT=ENV['TARGET']&.split(',')&.map(&:to_i)
# RESTRICTED_POINTS=ENV['RESTRICTED']&.split(';')&.map { |i| i.split(',').map(&:to_i) }

puts "Enter start point. Valid format is 1,1,1"
start_point = gets.gsub(/\s/, '').split(',')
start_point = [0, 0, 0] if start_point.empty?

puts "\nEnter target_point point. Valid format still is 1,1,1"
target_point = gets.gsub(/\s/, '').split(',').map(&:to_i)
raise 'target variable must be valid' if target_point.nil? || target_point.empty?

puts "\nEnter count of safe levers"
levers_count = [gets.to_i, 3].max

puts "\nEnter restricted points. Valid format is 1,1,1;2,2,2. Where ',' is for point separator and ';' is points separator"
restricted_points = gets.split(';').map { |i| i.split(',').map(&:to_i) }

puts "\nSo your variables are:"
puts "levers_count: #{levers_count}"
puts "start_point: #{start_point}"
puts "target_point: #{target_point}"
puts "restricted_points: #{restricted_points}"

service = UnlockStepsBuilder.new(
	levers_count: levers_count,
	start_point: start_point,
	target_point: target_point,
	restricted_points: restricted_points
)
service.call

puts 'Result:'
puts service.visited_points.map(&:inspect)