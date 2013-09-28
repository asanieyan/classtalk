class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :commentable, :polymorphic => true

  escape_once_and_truncate 'body'
  validates_length_of 'body',:minimum=>1,:too_short=>"Please provide a longer post." 

end
