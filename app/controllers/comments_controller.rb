class CommentsController < ApplicationController
  def new
    @comment = Comment.new
    @comments = Comment.order('created_at DESC')
  end
 
  def create
    respond_to do |format|
      if current_user
        @game = Game.find(params[:game_id])
        sender = current_player(@game)
        msg = Comment.parse_comment(comment_params[:body])
        case msg[:type]
        when :role
          if current_player(@game).role == "werewolf"
            @game.broadcast_to_role(msg[:target].to_s, msg[:body], sender)
            @private = true
          else
            @error = true
          end
          format.html {redirect_to root_url}
          format.js
          return
        # when :private
        #  target.private_message(msg[:body], sender)
        #  @private = true
        # format.html {redirect_to root_url}
        # format.js
        # return
        else
          body = comment_params[:body]        
          gon.channel = @game.channel
          @comment = current_player(@game).comments.build(body: body)
          @comment.game_id = @game.id
          if @comment.save
            flash.now[:success] = 'Your comment was successfully posted!'
          else
            flash.now[:error] = 'Your comment cannot be saved.'
          end
          format.html {redirect_to root_url}
          format.js
        end
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