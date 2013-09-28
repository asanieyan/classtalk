module ReportHelper
  def select_subjects select_options,selected_options = nil
       select_tag("rs",
        options_for_select(select_options.map{|s| [s,select_options.index(s).to_s]}.unshift(["Choose one..","-1"]),
        selected_options))       
  end
end