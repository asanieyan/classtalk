Info = {
    :name=>"Cincinnati",
    :nid=>"16777431",
    :city=>"cincinnati",
    :region=>"ohio",    
    :country=>"united states",
    :semesters=>[
      ["Autumn","9/15","12/25"],
      ["Winter","1/1","3/25"],
      ["Spring","3/26","6/16"],
      ["Summer","6/17","8/30"]
    ]
}          
class CincinnatiParser < CourseParser
    def start
      parse(get("http://www.onestop.uc.edu/learningopp/search.asp")).inner_html[/function writeDiscipline().*?}/mi].scan(/<option value='.*?'>.*?<\/option>/).each do |option|

        text = option.sub(/<.*?>(.*?)<\/.*?>/,'\1')
        s_code = text.split(' - ')[0]
        s_name = text.split(' - ')[1]

        xsubject = get_subject(s_code, s_name)

        disc_url = "http://www.onestop.uc.edu/learningopp/searchresults.asp?termcode=07A&alltermcode=%2707A%27&collcode=&disccode=#{s_code}&day1=M&day1=W&day1=F&day1=T&day1=H&timeselect=any&starttime_hr=6&starttime_min=00&starttime_mark=AM&endtime_hr=10&endtime_min=00&endtime_mark=PM&bok=&deliverymode=&keyword=&searchbutton=Search"

        parse(get(disc_url)).search("tr[@bgcolor]").each do |tr_tag|
	  if tr_tag.attributes['bgcolor'] =~ /cccccc|ffffff/i and tr_tag.inner_html =~ /javascript\:popCourse/ then
            course_call_number = tr_tag.inner_html.sub(/.*?popCourse\((.*?)\).*/mi,'\1').gsub(/[\s\D]+/,'')
            c_credits = tr_tag.search("td > font > b")[1].inner_html.sub(/.*\((.*?)\).*/,'\1').gsub(/[A-Za-z]|\*/,'').sub(/\d?\-?(\d+)/,'\1')

	    popup_page = parse(get("http://www.onestop.uc.edu/learningopp/courseDetail.asp?course_ID=#{course_call_number}")).search("font")

            c_name = popup_page[0].inner_html
            c_number = popup_page[1].at("b").inner_html.sub(/.*?#{s_code} (.*?)/,'\1')
            c_description = popup_page[2].inner_html


            puts c_number + " " + c_name + " " + c_credits
            puts c_description

            xcourse = xsubject.get_course(c_number, c_name, c_description, c_credits)

 	    puts "*"*40

          end          
        end

      end
      
      
    end
end
