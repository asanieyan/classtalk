Info = {
    :name=>"Colorado",
    :nid=>"16777319",
    :city=>"boulder",
    :region=>"colorado",    
    :country=>"united states",
    :semesters=>[
      ["Fall","8/25","12/25"],
      ["Spring","1/14","5/9"],
      ["Summer A","6/2","7/3"],
      ["Summer B","7/8","8/8"],
      ["Summer C","6/2","7/25"],
      ["Summer D","6/2","8/8"],
      ["Summer M","5/12","5/30"]
    ],
    :paths=>[
      ["Fall","Spring","Summer A"],
      ["Fall","Spring","Summer B"],
      ["Fall","Spring","Summer C"],
      ["Fall","Spring","Summer D"],
      ["Fall","Spring","Summer M"]
    ]
}          
class ColoradoParser < CourseParser
    def start

      recursive_parse("http://www.colorado.edu/catalog/catalog07-08/index.pl?c")
      
    end

    def recursive_parse(address=nil, level=0, subject_name=nil)
      
      page = parse(get(address))
      return if [
                 "http://www.colorado.edu/catalog/catalog07-08/index.pl?c=10"].include?(address)
      
      if level == 2 then
        subject_name = page.at("div[@class='mainContent']").at("strong").inner_html
      elsif level == 1 && address =~ /\?c=5/ then
        subject_name = page.at("div[@class='mainContent']").at("strong").inner_html       
      end
      
      
      if page.inner_html =~ /Please choose from one of the following subsections/ then
        new_level = level+1
        page.at("div[@class='mainContent']").search("li > a").each do |link|
          get_subject_code = recursive_parse("http://www.colorado.edu/catalog/catalog07-08/#{link.attributes['href']}", new_level, subject_name)
        end
        return false
      else
        page.at("div[@class='mainContent']").search("p").each do |course|
          
          if course.inner_html =~ /<b>.*?<\/b>/ then
            course_data = course.at('b').inner_html
            code_num,name,null = course_data.split(".")                                
            name.strip!
            code_num.strip!
        
            code,num,cc = code_num.split(" ",3)
            cc = cc ? cc.slice(/[^()]+/) || 0 : 0 
            if !code or !num or code !~ /^[A-Z]+$/ or num !~ /\d+/
                puts code
                puts num
                raise unless confirm("continue ")
            end
            subject_name = case code
                              when "LAWS";"Law"
                              when "JOUR";"Journalism"  
                              when "MBAC";"Master of Business Administration"
                              when "MBAX";""
                              when "SOCY";"Sociology"
                              when "EDUT";"Education"
                              else
                                subject_name
                           end           
            xsubject = get_subject(code, subject_name)
            cdesc = course.at("span").inner_html.gsub(/<a.*?>(.*?)<\/a>/,'\1') rescue ""
            xsubject.get_course(num,name,cdesc,cc) 
          end
        end
        return false      
      end
    
    end

end
