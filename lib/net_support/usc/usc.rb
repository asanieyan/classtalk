require 'json'

Info = {
    :name=>"USC",
    :nid=>"16777251",
    :city=>"los angeles",
    :region=>"california",    
    :country=>"united states",
    :semesters=>[
      ["Fall","8/25","12/25"],
      ["Spring","1/1","5/15"],
      ["Summer","5/21","8/15"]
    ]
}          
class UscParser < CourseParser
    def start
      #did i say i hated javascript? i meant i love a challenge. lemme break it down right here..
      
      ['20073'].each do |term|
      
        subject_data = JSON.load(parse(get("http://web-app.usc.edu/ws/soc/api/departments/#{term}")).inner_html)

        subject_codes = Array.new

        subject_data['department'].each do |subject|
          
          if !subject_codes.include?(subject['code']) then
            subject_codes << subject['code']
            xsubject = get_subject(subject['code'], subject['name'])

            course_json = parse(get("http://web-app.usc.edu/ws/soc/api/courses/#{subject['code'].downcase}/#{term}")).inner_html

            if course_json != "" then

              course_data = JSON.load(course_json)

              course_data["Courses"].each do |course|
              
                c_name = course['title']
                c_number = course['number']
                c_credits = course['units'][/\d+$/]
                c_description = "no description"

                c_description_json = parse(get("http://web-app.usc.edu/ws/soc/api/course/#{course['prefix']}/#{course['PublishedCourseID']}/#{term}")).inner_html

                if c_description_json != "" then
                  c_description_data = JSON.load(c_description_json)
                  c_description = c_description_data['description']
                end
puts course['PublishedCourseID'] + " " + c_name
                xcourse = xsubject.get_course(c_number,c_name,c_description,c_credits)

              end

            end
          end

        end
      
      end
    end
end
