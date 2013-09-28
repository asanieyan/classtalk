Info = {
    :name=>"Arizona",
    :nid=>"16777318",
    :city=>"tuscon",
    :region=>"arizona",    
    :country=>"united states",
    :semesters=>[
      ["Fall","8/20","12/25"],
      ["Spring","1/1","5/16"],
      ["Summer I","6/9","7/10"],
      ["Summer II","7/14","8/14"]
    ]
}          
class ArizonaParser < CourseParser
    def start
      parse(get("http://catalog.arizona.edu/2007%2D08/courses/aaindex.html")).search("span[@class='courseLinksFall'] > a").each do |link|
        if link.attributes['href'] !~ /http\:\/\/|#|tier\d|GRCENWC|hsvx|IRLV|lcex|rncx/ then

          puts "accessing #{link.attributes['href']}"

          page = parse(get("http://catalog.arizona.edu/2007%2D08/courses/#{link.attributes['href']}")).inner_html
          
          subjectline = page[/<p><b>.*?<\/b>.*Department Info/mi].sub(/.*<b>(.*?)<\/b>.*/, '\1')
          s_code = subjectline.sub(/.*?\((.*?)\).*$/, '\1')
          s_name = subjectline.sub(/(.*?)\(.*?\).*$/, '\1')

          xsubject = get_subject(s_code, s_name)
          courses = page.scan(/<!--#{s_code}{1}.*? start-->.*?ends-->/mi)
          courses.each do |course|
            if course =~ /Description/
            c_data = course[/<b>.*?<\/b>.*?<br/mi]
            c_number = c_data[/<a.*?>#{s_code} .*?<\/a>/].sub(/<a.*?>#{s_code} (.*?)<\/a>/,'\1')
            #print s_code + " " + c_number + " "
            c_name = c_data.sub(/.*?-- (.*?)<\/b>.*/mi,'\1').strip
            #print c_name + " "
            c_credits = c_data.sub(/.*\((.*?) units?\).*/mi,'\1').sub(/\d+?-?(\d+)/, '\1')
            #print c_credits + " "
            c_description = course[/Description\:<\/b>.*?(<b|<!--)/mi].sub(/.*<\/b>(.*).*/mi, '\1').gsub(/<a.*?>(.*?)<\/a>/, '\1').gsub(/&nbsp;|\n|<!--|<b/,'').strip
            
            #puts "EOL"
            
            course = xsubject.get_course(c_number,c_name,c_description,c_credits)
            end
          end
        end
      end
    end
end
