require 'rails_helper'

RSpec.describe NamesController, type: :controller do

  describe "GET #match" do
    it "returns http success" do
      get :match
      expect(response).to have_http_status(:success)
    end
  end

end
