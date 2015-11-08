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

private
  def name_params
    params.require(:name).permit(:your_name, :friend_name)
  end
end
