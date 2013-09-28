Info = {
    :name=>"Michigan",
    :nid=>"16777239",
    :city=>"ann arbor",
    :region=>"michigan",    
    :country=>"united states",
    :semesters=>[
      ["Fall","9/1"],
      ["Winter","1/1"],
      ["Spring","5/1"],
      ["Summer","6/25"]  
    ]
}          
class MichiganParser < CourseParser
    def start         
         line_num = 1
         urls = ["http://www.umich.edu/~regoff/timesched/pdf/FA2007.csv",
                 "http://www.umich.edu/~regoff/timesched/pdf/WN2007.csv",
                 "http://www.umich.edu/~regoff/timesched/pdf/SP2007.csv",
                 "http://www.umich.edu/~regoff/timesched/pdf/SS2007.csv",
                 "http://www.umich.edu/~regoff/timesched/pdf/SU2007.csv"
                 ]
         urls.each do |url|
           get(url).split("\n").each do |line|
              begin
                if line_num > 1
                  sections = line.scan(/".*?"/).map{|s| s.gsub(/"/,'')}            
                  subject_section = sections[4]
                  s_name = subject_section[0..subject_section.index("(")-1].strip
                  c_num = sections[5]
                  c_name = sections[7]
                  s_code = subject_section[subject_section.index("(")+1..subject_section.index(")")-1]            
                  get_subject(s_code,s_name).get_course(c_num,c_name,"",0)
                else
                  line_num += 1
                end
              rescue
              
              end
  
           end
         end
    end
end
