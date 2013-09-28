Info = {
    :name=>"Fraser Valley",
    :nid=>"16778196",
    :city=>"abbotsford",
    :region=>"british columbia",    
    :country=>"canada",
    :semesters=>[
      ["Fall","9/1","12/20"],
      ["Winter","1/1","4/20"],
      ["Summer","5/1","8/20"]
    ]
}          
class FraserValleyParser < CourseParser
    def start

      parse(get("http://www.ucfv.ca/calendar/2007_08/CourseDescriptions/index.htm")).at("select[@name='Courses']").search("option").each do |option|

        if option.inner_html =~ / - / then
          s_code = option.inner_html.split(' - ')[0]
          s_name = option.inner_html.split(' - ')[1]
          xsubject = get_subject(s_code, s_name)
#puts s_code + " " + s_name
          parse(get("http://www.ucfv.ca/calendar/2007_08/#{option.attributes['value']}")).search("p[@class='keepTogether']").each do |p_tag|
            info = p_tag.at("span[@class='courseTitle']")
            if !info.nil? then
              c_number = info.at("a").attributes['name'].strip
              c_name = info.inner_html.gsub(/<.*?>.*?<\/.*?>/,'').gsub(/<\/?.*?>/,'').strip
              c_credits = info.at("span[@class='right']").inner_html.sub(/ credits?/,'').strip
#puts c_number +  " " + c_name + " " + c_credits
            end
            c_description = p_tag.at("span[@class='courseDescription']").inner_html rescue c_description = "no description"
#puts ""
	    xcourse = xsubject.get_course(c_number, c_name, c_description, c_credits)
          end
        end

      end
      
    end
end
