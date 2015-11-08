class NamesController < ApplicationController
  include NamesHelper

  def match
    @name = {}
    @name[:your_name] = params[:your_name] || "테스트"
    @name[:friend_name] = params[:friend_name] || "테스트"
    @name[:your_count] = count_strokes @name[:your_name]
    @name[:friend_count] = count_strokes @name[:friend_name]
    @name[:strokes] = to_strokes @name[:your_name], @name[:friend_name]
  end

  def try
  end

  def test
    begin
      @name = {}
      @name[:your_name] = params[:your_name] || "테스트"
      @name[:friend_name] = params[:friend_name] || "테스트"
      @name[:matching_point] = to_strokes_global @name[:your_name], @name[:friend_name]
      puts @name.inspect
      redirect_to try_path({name: @name}), { success: "Check it out!" }
    rescue => e
      redirect_to try_path, { success: "Something wrong!" }
    end
  end

private
  def name_params
    params.require(:name).permit(:your_name, :friend_name)
  end
end
