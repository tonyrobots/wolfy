class CommentsController < ApplicationController
  def new
    @comment = Comment.new
    @comments = Comment.order('created_at DESC')
  end
 
  def create
    respond_to do |format|
      if current_user
        @game = Game.find(params[:game_id])
        @comment = current_player(@game).comments.build(comment_params)
        if @comment.save
          flash.now[:success] = 'Your comment was successfully posted!'
        else
          flash.now[:error] = 'Your comment cannot be saved.'
        end
        format.html {redirect_to root_url}
        format.js
      else
        format.html {redirect_to root_url}
        format.js {render nothing: true}
      end
    end
  end
end

private
 
def comment_params
  params.require(:comment).permit(:body)
end