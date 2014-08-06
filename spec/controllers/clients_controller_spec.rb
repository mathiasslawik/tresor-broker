require 'spec_helper'

describe ClientsController do

  describe 'GET #index' do
    include_context 'with existing clients'

    it "responds with an HTTP 200 status code and the list of clients" do
      get :index, :format => :xml

      expect(response).to be_success
      expect(response.status).to eq(200)

      expect(assigns[:clients]).to have_exactly(3).clients
    end
  end

  describe 'GET #show' do
    include_context 'with existing clients'

    it 'responds with an HTTP 200 status code and shows a single client' do
      get :show, :id => Client.first._id, :format => :xml

      expect(response).to be_success
      expect(response.status).to eq(200)

      expect(assigns[:client]).to eq Client.first
    end

    it 'returns a 404 error if the client cannot be found' do
      get :show, :id => 'ABC123', :format => :xml

      expect(response).to be_missing
      expect(response.status).to eq(404)
    end
  end

  describe 'POST #create' do
    after(:each) do
      Client.delete_all
    end

    it 'responds with 201 and returns the correct client URL' do
      post :create, :client_data => 'client data', :client_profile => 'client profile'

      expect(response).to be_success
      expect(response.status).to eq(201)
      expect(response['Location']).to eq(client_url(Client.first))
    end
  end

  describe 'PUT #update' do
    after(:each) do
      Client.delete_all
    end

    it 'creates a new client and responds with 201 if the client did not exist' do
      put :update, :id => 'new-id', :client_data => 'client data', :client_profile => 'client profile'

      expect(Client.find('new-id').client_data).to eq 'client data'

      expect(response).to be_success
      expect(response.status).to eq 201
    end

    it 'updates an existing client and responds with 204' do
      client = Client.create(:client_data => 'old', :client_profile => 'old')

      put :update, :id => client._id, :client_data => 'new'

      client.reload

      expect(response).to be_success
      expect(response.status).to eq 204

      expect(client.client_data).to eq 'new'
      expect(client.client_profile).to eq 'old'
    end

    it 'responds with 422 if the id was missing' do

    end
  end

  describe 'DELETE #delete' do
    after(:each) do
      # If the test fails, leave a clean database
      Client.delete_all
    end

    it 'deletes a client and returns 204' do
      client = Client.create

      delete :destroy, id: client._id

      expect(response).to be_success
      expect(response.status).to eq(204)

      expect {Client.find(client._id)}.to raise_exception Mongoid::Errors::DocumentNotFound
    end

    it 'returns a 404 error if the client cannot be found' do
      delete :destroy, id: 'ABC'

      expect(response).to be_missing
      expect(response.status).to eq(404)
    end
  end
end