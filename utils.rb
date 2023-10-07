def linspace(min, max, step)
  points = ((max-min)/step).to_i
  [*0..points].collect {|i| min + i*step}
end

def modify_run_card proc_dir, muR, muF
  file_name = File.join(proc_dir, 'Cards', 'run_card.dat')
  file = File.read(file_name)
  lines = file.each_line.to_a
  temp = lines[87].split(' ')
  temp[0] = muR.to_f.to_s
  lines[87] = temp.join(' ') + "\n"
  temp = lines[88].split(' ')
  temp[0] = muF.to_f.to_s
  lines[88] = temp.join(' ') + "\n"
  File.open(file_name, "w") {|f| f.puts lines.join}
end

def change_mass_on_line_num lines, mass, line_nr
  temp = lines[line_nr].split(' ')
  temp[1] = mass.to_s
  lines[line_nr] = temp.join(' ') + "\n"
  lines
end

def change_width_on_line_num lines, mass, line_nr
  temp = lines[line_nr].split(' ')
  temp[2] = mass.to_s
  lines[line_nr] = temp.join(' ') + "\n"
  lines
end

def modify_param_card proc_dir, msq, mglu, mO
  file_name = File.join(proc_dir, 'Cards', 'param_card.dat')
  file = File.read(file_name)
  lines = file.each_line.to_a
  lines = change_mass_on_line_num lines, msq.to_f, 14
  [*25..36].each do |line_nr|
    lines = change_mass_on_line_num lines, msq.to_f, line_nr 
  end
  lines = change_mass_on_line_num lines, mO.to_f, 38
  lines = change_mass_on_line_num lines, Math.sqrt(mO.to_f**2 + 4.0*mglu.to_f**2), 37
  lines = change_mass_on_line_num lines, mglu.to_f, 59
  lines = change_mass_on_line_num lines, mglu.to_f, 65
  lines = change_width_on_line_num lines, Math.sqrt(1e-5)*mglu.to_f, 89
  File.open(file_name, "w") {|f| f.puts lines.join}
end

def read_output(proc_dir, run_name)
  file = File.open(File.join(proc_dir, 'Events', run_name, 'MADatNLO.HwU'))
  file_data = file.readlines.map(&:chomp)


  header = file_data[0].split('&').map(&:strip).drop(1)

  idx = file_data.find_index('<histogram> 5 "total rate |X_AXIS@LIN |Y_AXIS@LOG |TYPE@#1"') + 1
  data = file_data[idx].split(' ').map(&:strip).map(&:to_f)

  if header.length != data.length
    puts "Error: diffent number of elements - header (#{header.length}) vs. row (#{data.length})"
    exit 1
  end

  header.each_with_index do |e, i|
    puts "#{e} = #{data[i]}"
  end

  pdfs = data[-42..-1]

  scales = data[11..18]

  central_value = data[2]

  [central_value] + scales + pdfs 
end
