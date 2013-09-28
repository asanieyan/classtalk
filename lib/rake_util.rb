argv = ARGV; #to get rid of the task passes as argument
argv.shift;
$argv = {}
argv.each do |arg|
  k,v = arg.split("=")
  v = v.split(",").map{|vi| v.intern}
#  v = v.pop if v.size == 1
  $argv[k.intern] = v
end
module Kernel::Confirmation
  def in_read
    STDIN.readline.strip
  end
  def prompt q 
    p q
    in_read
  end
  def show(message)
     puts message
  end
  def confirm(message,options={})
        answ = %w(yes no)
        answ << "ay" if options.delete(:always_yes)
        answ << "an" if options.delete(:always_no)
        answ_str = answ.join("|")
        message += " [#{answ_str}]"
        show(message)        
        answer = STDIN.readline.strip
        if answ.include?(answer)            
            if answer == "yes" or answer == "ay"
                @always_yes = answer == "ay"
                return true
            else
                @always_no = answer == "an"
                return false
            end
        end
        while not %w(yes no).include?(answer)
            p 'Please enter with yes or no'
            show(message)
            answer = STDIN.readline.strip
        end    
        return answer == "yes"
  end
end