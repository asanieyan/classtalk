module ExceptionNotifierHelper
  VIEW_PATH = "views/exception_notifier"
  APP_PATH = "#{RAILS_ROOT}/app/#{VIEW_PATH}"

  def render_section(section)
    summary = render_overridable(section).strip
    unless summary.blank?
      title = render_overridable(:title, :locals => { :title => section }).strip
      "#{title}\n\n#{summary.gsub(/^/, "  ")}\n\n"
    end
  end

  def render_overridable(partial, options={})
    if File.exist?("#{APP_PATH}/_#{partial}.rhtml")
      render(options.merge(:file => "#{APP_PATH}/_#{partial}.rhtml", :use_full_path => false))
    else
      render(options.merge(:file => "#{File.dirname(__FILE__)}/../#{VIEW_PATH}/_#{partial}.rhtml", :use_full_path => false))
    end
  end
end
