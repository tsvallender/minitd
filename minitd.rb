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
    yesterdays_file = STORAGE_PATH.join(Date.yesterday.strftime("%F"))
    # Loop through previous day's tasks, update statuses
    # Loop through adding new items to today
  end

  desc "-u", "Update a task status"
  def update_task_status
    # Print tasks with keys, input one to update status
  end

  desc "-p", "Print plan in Markdown"
  def print_markdown
  end

  private

    def add_to_list(task, date: Date.today)
      dir = File.join(STORAGE_PATH, date.strftime("%Y-%m"))
      FileUtils.mkdir_p(dir) unless File.directory?(dir)
      file = File.join(dir, date.strftime("%d"))

      File.write(file, "#{task}\n", mode: "a+")
    end
end

MiniTd.start(ARGV)
