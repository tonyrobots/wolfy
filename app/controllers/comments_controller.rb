class CommentsController < ApplicationController
  def new
    @comment = Comment.new
    @comments = Comment.order('created_at DESC')
  end

  def create #this uses the target param for private/role messages
    respond_to do |format|
      if params[:target] == "admin" and current_user.is_admin?
        #admin broadcast
        @game = Game.find(params[:game_id])
        @game.add_message(comment_params[:body])
      elsif current_user
        @game = Game.find(params[:game_id])
        sender = current_player(@game)
        target_id = params[:target]
        body = comment_params[:body]
        @comment = sender.comments.build(body: body,game_id:@game.id)
        unless target_id.blank?
          # TODO generalize this to work with other roles
          if target_id == "werewolves"
            if sender.role == "werewolf"
              @comment.target_role = "werewolf"
              #gon.channel = "/channel-w-#{@game.id}"
              @squelch = true
              puts "wolf message"
            end
          elsif target = Player.find(target_id)
            @private = true
            #gon.channel = target.channel
            @comment.target = target
            puts "private message"
          else
            @squelch = true
            format.html {redirect_to root_url}
            format.js
            return
          end
        end

        if @comment.save
          # send a copy back to the sender (already sent to receiver)
          sender.private_send(@comment) if @private

          @game.broadcast_comment_to_role(@comment, "werewolf") if @comment.target_role == "werewolf"
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

  def create_not_in_use #this parses the message to use /w or /p for private/role messages
    respond_to do |format|
      if current_user
        @game = Game.find(params[:game_id])
        sender = current_player(@game)
        msg = Comment.parse_comment(comment_params[:body])
        body = msg[:body]
        @comment = sender.comments.build(body: body,game_id:@game.id)
        case msg[:type]
        when :role
          if current_player(@game).role == "werewolf"
            #@game.broadcast_to_role(msg[:target].to_s, msg[:body], sender)
            @comment.target_role = msg[:target]
            @squelch = true
          else
            @squelch = true
          end
        when :private
          if target = Player.find_by_alias(msg[:target])
            #target.private_message(msg[:body], sender)
            @private = true
            gon.channel = target.channel
            @comment.target = target
          else
            @squelch = true
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

  private

  def comment_params
    params.require(:comment).permit(:body,:target)
  end
end
