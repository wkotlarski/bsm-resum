require 'open3'
require 'csv'
require_relative 'utils'

$proc_dir = File.join(Dir.pwd, ARGV[0])

def calc(msq, mglu, mO)
  modify_run_card $proc_dir, ARGV[2].to_f, msq, msq
  modify_param_card $proc_dir, msq, mglu, mO

  run_dir = "scan_#{ARGV[2]}TeV_#{msq}_#{mglu}_#{mO}"

  #Open3.popen3('./bin/calculate_xsect', '-f', "-n #{run_dir}", :chdir=>$proc_dir) do |stdin, stdout, stderr, wait_thr|
  #  while line = stdout.gets
  #    puts line
  #  end
  #  exit_status = wait_thr.value
  #  puts exit_status
  #  unless exit_status.success?
  #    puts stdout.gets
  #    puts stderr.gets
  #    abort "MadGraph run FAILED!!!"
  #  end
  #end
  o, e, s = Open3.capture3('./bin/calculate_xsect', '-f', "-n #{run_dir}", :chdir=>$proc_dir)
  puts o
  puts e

  res = read_output $proc_dir, run_dir
end

data_file = $proc_dir + "_#{ARGV[2]}TeV.data"

if File.exist? data_file
  csv = CSV.read(data_file, converters: :numeric, col_sep: ' ')
end

#msq_a = linspace(500.0, 1700.0, 100.0)
msq_a = linspace(500.0, 3000.0, 50.0)
mglu_a = linspace(500.0, 3000.0, 50.0)
#mglu_a = [5000, 10000, 20000, 50000, 100000]
mO_a = [2000.0, 100000.0]

$i = 0
msq_a.each do |msq|
  mglu_a.each do |mglu|
    mO_a.each do |mO|
      break if $i >= ARGV[1].to_i
      input = [msq, mglu, mO]
      if !csv.nil?
        idx = csv.find_index {|el| el.take(3) == input}
        next if !idx.nil?
      end
      File.open(data_file, 'a') {|f| f.puts (input + calc(*input)).join(' ')}
      $i+=1
    end
  end
end
