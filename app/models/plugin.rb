class Plugin < ActiveRecord::Base

  def before_save
    self["name"] = name
    self["description"] = description
  end
  def name
    raise "name need to be filledout by the subclasses"
  end
  def description
    raise "name need to be filledout by the subclasses"
  end
end