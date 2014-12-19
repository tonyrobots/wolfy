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
        body = msg[:body] 
        @comment = current_player(@game).comments.build(body: body,game_id:@game.id)
        case msg[:type]
        when :role
          if current_player(@game).role == "werewolf"
            @game.broadcast_to_role(msg[:target].to_s, msg[:body], sender)
            @error = true
          else
            @error = true
          end
          format.html {redirect_to root_url}
          format.js
          return
        when :private
          if target = Player.find_by_alias(msg[:target])
            #target.private_message(msg[:body], sender)
            @private = true
            gon.channel = target.channel
            @comment.target = target
          else
            @error = true
            format.html {redirect_to root_url}
            format.js
            return
          end
        else
          # public broadcast
          gon.channel = @game.channel    
        end #end case switch statement
          
        if @comment.save
          flash.now[:success] = 'Your comment was successfully posted!'
          sender.private_send(@comment) if @private
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
  params.require(:comment).permit(:body,:target)
end