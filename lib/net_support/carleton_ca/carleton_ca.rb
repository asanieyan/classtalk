Info = {
    :name=>"Carleton CA",
    :nid=>"16778121",
    :city=>"ottawa",
    :region=>"ontario",    
    :country=>"canada",
    :semesters=>[

  ["Fall","9/1","12/20"],
  ["Winter","1/3","5/1"],
  ["Summer Full","5/12","7/10"],
  ["Summer Early","5/12","6/30"],
  ["Summer Late","7/2","8/19"] 
 
 
  

    ]
}          
class CarletonCaParser < CourseParser
    def start

      parse(get("http://www.carleton.ca/cu0708uc/courses/byprefix.html")).inner_html.scan(/<a href="[A-Z]{3,4}">[A-Z]{3,4}<\/a>/).each do |link|
        s_code = link.sub(/<a href="(.*?)">.*/,'\1')
	listpage = parse(get("http://www.carleton.ca/cu0708uc/courses/#{s_code}/"))
        s_name = listpage.at("div[@class='maincontent']").at("h1").inner_html.gsub(/<.*?>|\(.*?\)/,'')

        puts ""
        puts "*"*40
        puts s_code + " " + s_name
	puts ""

        xsubject = get_subject(s_code, s_name)

        listpage.at("div[@class='maincontent']").search("a").each do |clink|
          if clink.attributes['href'] =~ /\d+/ then
            page = parse(get("http://www.carleton.ca/cu0708uc/courses/#{s_code}/#{clink.attributes['href']}")).at("div[@class='course']")

            c_number = clink.inner_html.sub(/#{s_code}/,'').strip
            c_name = page.at("h4").inner_html
            c_credits = page.at("h3").inner_html.sub(/.*?\[(.*?)].*/,'\1').sub(/[a-z ]+/,'')
            c_description = page.inner_html.gsub(/<a.*?>(.*?)<\/a>/,'\1').gsub(/<.*?>.*?<\/.*?>|&nbsp;/,' ').sub(/^(.*?)<br.*/mi,'\1').strip
            xcourse = xsubject.get_course(c_number,c_name,c_description,c_credits);
          end
        end
      end
      
    end
end
