#!/usr/bin/ruby

# Task v1 by Keyvan Fatehi, Feb 19 2010
# A script for integrating a task or to-do list into your terminal
# useful for OS X, Linux, or Unix users that use the terminal constantly
# I recommend setting an alias called 'task' to this file in your .bashrc 
# It will create a database file called ".task.db" in your home directory.

require 'rubygems'
require 'sqlite3'
require 'etc'

# Core Functions
def open_database(filename)
  Dir.chdir(Etc.getpwuid.dir)
  if File.exist?(filename)
    @db = SQLite3::Database.new(filename)
  else
    @db = SQLite3::Database.new(filename)
    @db.execute("CREATE TABLE tasks (time varchar(40), task varchar(255))")
  end
end

def add(task)
  time = Time.now.strftime("%m-%d-%Y %I:%M%p").to_s
  @db.execute("INSERT INTO tasks VALUES ('#{time}', \"#{task}\")")
  puts "Added task: [#{time}] [#{task}]"
end

def ready_destroyer
  rows = @db.execute("SELECT * FROM tasks")
  row_count = 0
  @destroyer = {}
  rows.each do |row|
    row_count+=1
    @destroyer[row_count] = row
  end
end

def tasks
  rows = @db.execute("SELECT * FROM tasks")
  row_count = 0
  $destroyer = {}
  rows.each do |row|
    print "[#{row_count+=1}] "
    $destroyer[row_count] = row
    row.each do |value|
      print "[#{value}] "
    end
    print "\n"
  end 
  puts "You have no tasks." unless row_count > 0
end

def destroy(row_number)
  target = @destroyer[row_number]
  @db.execute("DELETE FROM tasks WHERE task = '#{target[1]}'")
  puts "Destroyed task: [#{target[0]}] [#{target[1]}]"
end

# Argument handling
if ARGV == []   # No argument, just display the tasks
  open_database(".task.db")
  tasks
elsif ARGV[0] == "add" && ARGV[1].class == String   # task add "somejunk", add a task to the database
  open_database(".task.db")
  add("#{ARGV[1]}")
elsif ARGV[0] == "destroy" && Integer(ARGV[1]).class == Fixnum  # task destroy 2, destroy 2nd task
  open_database(".task.db")
  ready_destroyer
  destroy(Integer(ARGV[1]))
elsif ARGV[0] == "help"   # task help, display help information
  puts "This Ruby script was written by Keyvan Fatehi and is free for use by anyone\n\n"
  puts "Viewing your tasks:"
  puts "                        task\n\n"
  puts "Adding a new task:"
  puts "                        task add \"Do the laundry!\"\n\n"
  puts "Destroying a task:"
  puts "                        task destroy #\n\n"
  puts "Acessing the help file:"
  puts "                        task help\n"
else
    puts "Invalid argument. See \"task help\""
end
  
