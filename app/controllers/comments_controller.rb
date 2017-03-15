class CommentsController < ApplicationController
  before_filter :load_recognition
  filter_access_to :all, attribute_check: true
  filter_access_to :create, attribute_check: false

  def create
    @comment = @recognition.comments.build(params[:comment].merge(commenter: current_user))
    @comment.save
    
   @comment.delay(queue: 'priority').post_yammer_recognition_comment!(Recognize::Application.yammer_client)

    comment_partial = @comment.persisted? ? render_to_string( @comment) : ''
    respond_with @comment, onsuccess: {method: "fireEvent", params: {name: "comment_add", recognition_id: @recognition.id, comment:  comment_partial}}
  end

  def show
    @comment = Comment.find(params[:id])
  end

  # Because #edit is a GET request, we bypass Ajaxify, and thus must handle differently
  # this makes rendering something like the cancel link infinitely easier to implement
  # ie, it doesn't couple the javascript to the routing structure
  def edit
    @comment = Comment.find(params[:id])
  end

  def update
    @comment = Comment.find(params[:id])
    @comment.update_attributes(params[:comment])
  end

  def destroy
    @comment = Comment.find(params[:id])
    @comment.destroy
  end

  protected
  def load_recognition
    @recognition = Recognition.find(params[:recognition_id])
    
  end
end