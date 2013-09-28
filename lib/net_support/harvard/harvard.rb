Info = {
    :name=>"Harvard",
    :nid=>"16777217",
    :city=>"cambridge",
    :region=>"massachusetts",    
    :country=>"united states",
    :semesters=>[
      ["Fall","9/10","12/25"],
      ["Spring","1/1","5/28"],
      ["Summer","6/22","8/20"]
    ]
}          
class HarvardParser < CourseParser
    def start
      return
      parse(get("http://coursecatalog.harvard.edu/OASIS/CourseCat/search.jsp")).at("select[@name='schoolShortName']").search("option").each do |option|

        puts option.attributes['value'] + " " + option.inner_html
        
#        page = parse(get("http://coursecatalog.harvard.edu/OASIS/CourseCat/doSearch.jsp?allSchools=0&schoolShortName=#{option.attributes['value']}&allDepts=0&facNameFlag=0&facLastNameOpt=con&facLastName=&any_time=0&any_time=1&semesterSeason=*&semesterYear=*&titleSelectOp=AND&titleDescOption=&titleExclOption="))

  
#        links = Array.new
#        titles = Array.new
#        page.at("table[@class='niceWithBorder']").search("td > a").each do |link|
#          if !titles.include?(link.inner_html) then
#            titles << link.inner_html
#            links << link.attributes['href']
#          end
#        end
#  
#
#        links.each do |link|
#          link.sub!(/details.jsp;/,'details.jsp?')
#          link = URI.encode(link)
#          course = parse(get("http://coursecatalog.harvard.edu/OASIS/CourseCat/#{link}")).at("table[@class='niceWithBorder']").inner_html
#
#          c_number = course[/<table><tr><td>.*?<\/td><\/tr><\/table>/mi].sub(/^.*?<td>(.*?)<\/td>.*/mi,'\1').strip
#          c_name = course[/Course Title\:.*?<td class="regular">.*?<\/td>/mi].sub(/.*regular">(.*?)<\/td>/mi  ,'\1')
#          c_credits = course[/Credits\:.*?<td class="regular">.*?<\/td>/mi].sub(/.*regular">(.*?)<\/td>$/mi  ,'\1').sub(/N\/A/i,'0')
#          c_description = course[/Description\:.*?<td class="regular">.*?<\/td>/mi].sub(/.*regular">(.*?)<\/td>$/mi  ,'\1').strip
#
#          puts c_number + " " + c_name + " " + c_credits + " " + c_description
#        end
  
  
      end
    end
end
