Info = {
    :name=>"Georgetown",
    :nid=>"16777231",
    :city=>"washington",
    :region=>"district of columbia",    
    :country=>"united states",
    :semesters=>[

  ["Fall","8/25","12/25"],
  ["Spring","1/5","5/15"],
  ["Pre Summer","5/16","6/15"],
  ["Summer I","6/4","7/12"], 
  ["Summer 8WK","6/4","8/1"], 
  ["Summer II","7/9","8/15"] 
  

    ]
}          
class GeorgetownParser < CourseParser
    def start
      [2007,2006,2005].each do |eduyear|
      parse(get("http://courses.georgetown.edu/index.cfm?Action=HomePage&AcademicYear=#{eduyear}")).search("li > a").each do |link|
        s_name = link.inner_html.strip
        s_code = parse(get("http://courses.georgetown.edu/#{link.attributes['href']}")).at("div[@class='ParagraphText'] > table").search("tr > td > span[@class='CourseCode']")[0].inner_html.gsub(/\s+| {2,}/m, ' ').gsub(/> +</,'><').split('-')[0]
        puts s_code + " " + s_name
        xsubject = get_subject(s_code,s_name)

        parse_it = true

        tlink2 = link.attributes['href'].sub(/AcademicYear=200\d/, "AcademicYear=#{eduyear}")
        parse(get("http://courses.georgetown.edu/#{tlink2}")).at("div[@class='ParagraphText'] > table").search("tr > td > a").each do |sublink|

          tlink1 = sublink.attributes['href'].sub(/AcademicYear=200\d/, "AcademicYear=#{eduyear}")

puts "start"
puts eduyear.to_s + " " + s_code

          page = parse(get("http://courses.georgetown.edu/#{sublink.attributes['href']}"))
          mod_page = page.inner_html.gsub(/\s+| {2,}/m, ' ').gsub(/> +</,'><')

          c_number = page.at("h1 > span").inner_html.split('-')[1]
print c_number
          c_name = page.at("h1").inner_html.gsub(/\s+| {2,}/m, ' ').gsub(/> +</,'><').sub(/<span.*?>.*?<\/span>/,'')
print c_name
          c_credits = mod_page.sub(/.*Credits\: ([\d+]).*/i, '\1')
print c_number
          c_description = mod_page.sub(/.*<div class="ParagraphText">.*?<\/div><div class="ParagraphText">.*?<\/div><div class="ParagraphText">(.*?)<\/div><div class="ParagraphText">Credits\:.*/i, '\1')
puts "description"          
puts ""
puts ""
          xcourse = xsubject.get_course(c_number, c_name, c_description, c_credits)
           
        end
      end
      end
    end
end
