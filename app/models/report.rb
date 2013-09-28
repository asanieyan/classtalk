class Report < ActiveRecord::Base
  belongs_to :user
  belongs_to :reporter,:class_name=>"User"
  belongs_to :reportable, :polymorphic => true

  strip_tags_and_truncate 'body'
  validates_length_of 'body',:minimum=>10,:too_short=>"Please provide a longer comment for this report of offensive content."
  

end
