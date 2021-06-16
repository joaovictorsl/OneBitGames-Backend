require 'rails_helper'

RSpec.describe "Admin::V1::System Requirements as :admin", type: :request do
  let(:user) {create(:user)}

  context "GET /system_requirements" do
    let(:url) { "/admin/v1/system_requirements" }
    let!(:system_requirements) { create_list(:system_requirement, 5) }

    it "returns all System Requirements" do
      get url, headers: auth_header(user)
      expect(body_json['system_requirements']).to contain_exactly *system_requirements.as_json(only: %i[id name os storage processor memory video_board])
    end
    it "returns success status" do
      get url, headers: auth_header(user)
      expect(response).to have_http_status(:ok)
    end
  end

  context "POST /system_requirements" do
    let(:url) { "/admin/v1/system_requirements" }

    context "with valid params" do
      let(:system_requirement_params) { {system_requirement: attributes_for(:system_requirement)}.to_json }
      it 'adds a new System Requirement' do
        expect do
        post url, headers: auth_header(user), params: system_requirement_params
        end.to change(SystemRequirement, :count).by(1)
      end

      it 'returns last added System Requirement' do
        post url, headers: auth_header(user), params: system_requirement_params
        expect_system_requirement = SystemRequirement.last.as_json(only: %i[id name os video_board memory processor storage])
        expect(body_json['system_requirement']).to eq(expect_system_requirement)
      end

      it "returns success status" do
        post url, headers: auth_header(user), params: system_requirement_params
        expect(response).to have_http_status(:ok)
      end
    end

    context "with invalid params" do
      let(:system_requirement_invalid_params) do
        {system_requirement: attributes_for(:system_requirement, name: nil)}.to_json
      end

      it 'does not add a new Category' do
        expect do
          post url, headers: auth_header(user), params: system_requirement_invalid_params
        end.to_not change(Category, :count)
      end

      it 'returns error messages' do
        post url, headers: auth_header(user), params: system_requirement_invalid_params
        expect(body_json['errors']['fields']).to have_key('name')
      end

      it 'returns unprocessable_entity status' do
        post url, headers: auth_header(user), params: system_requirement_invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  context "PATCH /system_requirements/:id" do
    let(:system_requirement) { create(:system_requirement) }
    let(:url) {"/admin/v1/system_requirements/#{system_requirement.id}"}
    
    context "with valid params" do
      let(:new_name) { 'My new system requirement'}
      let(:system_requirement_params) { {system_requirement: {name: new_name}}.to_json}
      
      it 'updates System Requirement' do
        patch url, headers: auth_header(user), params: system_requirement_params
        system_requirement.reload
        expect(system_requirement.name). to eq(new_name)
      end

      it 'returns updated System Requirement' do
        patch url, headers: auth_header(user), params: system_requirement_params
        system_requirement.reload
        expect_system_requirement = system_requirement.as_json(only: %i[id name os video_board processor memory storage])
        expect(body_json['system_requirement']).to eq(expect_system_requirement)
      end

      it "returns success status" do
        patch url, headers: auth_header(user), params: system_requirement_params
        expect(response).to have_http_status(:ok)
      end
    end

    context "with invalid params" do
      let(:system_requirement_invalid_params) do
        {system_requirement: attributes_for(:system_requirement, name: nil)}.to_json
      end

      it 'does not update Category' do
        old_name = system_requirement.name
        patch url, headers: auth_header(user), params: system_requirement_invalid_params
        system_requirement.reload
        expect(system_requirement.name).to eq(old_name)
      end

      it 'returns error messages' do
        patch url, headers: auth_header(user), params: system_requirement_invalid_params
        expect(body_json['errors']['fields']).to have_key('name')
      end

      it 'returns unprocessable_entity status' do
        patch url, headers: auth_header(user), params: system_requirement_invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  context "DELETE /system_requirements/:id" do
    let!(:system_requirement) { create(:system_requirement) }
    let(:url) {"/admin/v1/system_requirements/#{system_requirement.id}"}

    it 'removes System Requirement' do
      expect do
        delete url, headers: auth_header(user)
      end.to change(SystemRequirement, :count).by(-1)
    end

    it "returns success status" do
      delete url, headers: auth_header(user)
      expect(response).to have_http_status(:no_content)
    end

    it 'does not return any body content' do
      delete url, headers: auth_header(user)
      expect(body_json).to_not be_present
    end

    it 'removes all associated games' do
      games = create_list(:game, 3, system_requirement: system_requirement)
      delete url, headers: auth_header(user)
      expected_games = Game.where(id: games.map(&:id))
      expect(expected_games.count).to eq(0)
    end
  end
end
