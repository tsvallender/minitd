#!/usr/bin/env ruby

require "date"
require "fileutils"
require "thor"

class MiniTd < Thor
  package_name "MiniTD"
  map "-a" => :add

  STORAGE_PATH = File.join(Dir.home, ".config", "minitd")
  STATUS = {
    done: "☑",
    todo: "☐",
  }

  desc "-a", "Add a todo for today"
  def add
    task = "#{STATUS[:todo]} #{STDIN.gets.chomp}"
    add_to_list(task)
  end

  desc "-s", "Start the day"
  def start_day
    if yesterday_file
      puts "What did you do yesterday?"
      yesterday_input = File.readlines(yesterday_file)
      yesterday_output = []
      today_output = []
      yesterday_input.each_with_index do |entry|
        entry = entry.chomp
        puts entry
        puts update_commands
        case STDIN.gets.chomp.downcase
        when "d"
          puts "Marking as done"
          yesterday_output << entry.gsub("☐", "☑")
        when "i"
          puts "Keeping as incomplete"
          yesterday_output << entry
        when "o"
          puts "Ongoing today"
          yesterday_output << entry
          today_output << entry
        when "t"
          puts "Moving to today"
          today_output << entry
        when "x"
          puts "Striking out"
          if entry.match(/\[([^\]]+)\]\(([^\)]+)\)/) # Markdown link
            yesterday_output << entry.gsub(/\[([^\]]+)\]\(([^\)]+)\)/) { "[#{$1.each_char.map { |c| c + "\u0336" }.join}](#{$2})" }
          else
            yesterday_output << "~#{entry}~"
          end
        when "k"
          puts "Removing"
        else
          raise "Unknown response"
        end
      end
    end

    puts "What are you doing today?"
    loop do
      input = STDIN.gets.chomp
      break if input == ""
      input = process_ticket(input) if input.start_with?("IBAT-")
      today_output << "☐ #{input}"
    end

    File.open(yesterday_file, "w") { |f| f.write(yesterday_output.join("\n")) }
    File.open(today_file, "w") { |f| f.write(today_output.join("\n")) }
  end

  desc "print", "Print plan"
  def print
    puts "*Y:* #{File.readlines(yesterday_file).map(&:chomp).join(" | ")}"
    puts "*T:* #{File.readlines(today_file).map(&:chomp).join(" | ")}"
  end

  private

    def add_to_list(task, date: Date.today)
      dir = File.join(STORAGE_PATH, date.strftime("%Y-%m"))
      FileUtils.mkdir_p(dir) unless File.directory?(dir)
      file = File.join(dir, date.strftime("%d"))

      File.write(file, "#{task}\n", mode: "a+")
    end

    def update_commands
      "D: Done I: Incomplete O: Ongoing T: Move to today X: Strike out K: Remove"
    end

    def process_ticket(ref)
      "[#{ref}](https://ibat-alliance.atlassian.net/browse/#{ref})"
    end

    def today_file
      File.join(STORAGE_PATH, Date.today.strftime("%Y-%m"), Date.today.strftime("%d"))
    end

    def yesterday_file
      max_steps, date = 30, Date.today - 1

      loop do
        file = File.join(STORAGE_PATH, date.strftime("%Y-%m"), date.strftime("%d"))
        return file if File.exist?(file)
        date -= 1
        max_steps -= 1
        return if max_steps.zero?
      end
    end
end

MiniTd.start(ARGV)
