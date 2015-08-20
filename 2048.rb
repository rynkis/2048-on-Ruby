=begin
puts "#------------------------------#"
puts "| Use your keyborad.           |"
puts "| W: Up A:Left S:Down D:Right  |"
puts "| Return: Next step            |"
puts "#------------------------------#"
puts "#------------------------------#"
puts "|Score:        0000000000000000|"
puts "#------------------------------#"
puts "#------+------+------+------#"
puts "|____2_|____2_|____2_|____2_|"
puts "├------+------+------+------┤"
puts "|____2_|____2_|____2_|____2_|"
puts "├------+------+------+------┤"
puts "|____2_|____2_|____2_|____2_|"
puts "├------+------+------+------┤"
puts "|_2048_|____2_|____2_|____2_|"
puts "#------+------+------+------#"
=end

$score = 0
$changed = false

lines = []; 4.times { lines << [nil, nil, nil, nil] }

helper        = -> {
                      puts "#------------------------------#"
                      puts "| Use your keyborad.           |"
                      puts "| W: Up A:Left S:Down D:Right  |"
                      puts "| Return: Next step            |"
                      puts "#------------------------------#"
                    }

score         = -> {
                      puts "#------------------------------#"
                      puts "|Score:        #{"%016d" % $score}|"
                      puts "#------------------------------#"
                    }

header        = -> { puts "#------+------+------+------#" }
block         = -> n { "_#{"_" * (4 - n.to_s.length)}#{n}_|" }
liner         = -> a { puts a.inject("|") {|m, i| m + block.call(i) }}
footer        = -> { puts "#------+------+------+------#" }

new_num = -> {
                loop do
                  x, y = rand(4), rand(4)
                  if lines[x][y].nil?
                    lines[x][y] = rand < 0.8 ? 2 : 4
                    break
                  end
                end
              }

start = -> { 2.times { new_num.call } }

restart = -> {
                loop do
                  puts "Play again? (Y/N)"
                  str = gets
                  case str.rstrip.to_sym
                  when :Y, :y
                    lines.clear; 4.times { lines << [nil, nil, nil, nil] }
                    $score = 0; new_num.call
                    break
                  when :N, :n; exit; end
                end
              }

game_over     = -> {
                      puts "#------------------------------#"
                      puts "|          Game Over!          |"
                      puts "#------------------------------#"
                      restart.call
                    }

congrulations = -> {
                      puts "#------------------------------#"
                      puts "|Congrulations!You've got 2048!|"
                      puts "#------------------------------#"
                      restart.call
                    }

refresh = -> { score.call; header.call; lines.each {|l| liner.call l }; footer.call}

complement = -> l { (4 - l.size).times { l << nil } if l.size < 4 }

arrange = -> line {
                    case line.size
                    # when 0, 1
                    when 2
                      if line[0] == line[1]
                        line[0] += line[1]; line[1] = nil; $score += line[0]
                      end
                    when 3
                      if line[0] == line[1]
                        line[0] += line[1]; line[1], line[2] = line[2], nil; $score += line[0]
                      elsif line[1] == line[2]
                        line[1] += line[2]; line[2] = nil; $score += line[1]
                      end
                    when 4
                      if line[0] == line[1]
                        line[0] += line[1]; line[1], line[2], line[3] = line[2], line[3], nil; $score += line[0]
                      end
                      if line[1] == line[2]
                        line[1] += line[2]; line[2], line[3] = line[3], nil; $score += line[1]
                      end
                      if !line[2].nil? && line[2] == line[3]
                        line[2] += line[3]; line[3] = nil; $score += line[2]
                      end
                    end
                  }

process = -> args {
                    rows = []
                    if args[0]
                      rows = lines
                    else
                      4.times { |i| rows << [ lines[3][i], lines[2][i], lines[1][i], lines[0][i] ] }
                    end
                    rows.each do |row|
                      row.reverse! if args[1]
                      row.compact!
                      arrange.call row
                      complement.call row
                      row.reverse! if args[1]
                      4.times { |i| lines[3][i], lines[2][i], lines[1][i], lines[0][i] = rows[i] } unless args[0]
                    end
                  }

left  = -> { process.call [ true, false] }
down  = -> { process.call [false, false] }
right = -> { process.call [ true,  true] }
up    = -> { process.call [false,  true] }

check = -> {
              lines.each { |l| l.each { |b| congrulations.call if b == 2048 } }
              game_over.call if lines.inject(0) {|mem, line| mem + line.compact.size } == 16
            }

game = -> {
            helper.call
            start.call
            loop do
              $nums  = 0
              image = []; lines.each { |l| image << l.clone }
              refresh.call
              str = gets
              case str.rstrip.to_sym
              when :a; left.call
              when :s; down.call
              when :d; right.call
              when :w; up.call;
              else next; end
              check.call
              new_num.call if image != lines
            end
          }

game.call
