# frozen_string_literal: true

require "spec_helper"

RSpec.describe CoronavirusForm::NhsNumberController, type: :controller do
  include_examples "redirections"
  include_examples "session expiry"

  let(:current_template) { "coronavirus_form/nhs_number" }
  let(:session_key) { :nhs_number }
  # randomly generated from http://danielbayley.uk/nhs-number/
  let(:valid_nhs_number) { "110 123 0614" }
  describe "GET show" do
    it "renders the form" do
      session[:live_in_england] = I18n.t("coronavirus_form.questions.live_in_england.options.option_yes.label")

      get :show
      expect(response).to render_template(current_template)
    end
  end

  describe "POST submit" do
    it "defaults the know your nhs number to Yes" do
      post :submit, params: { nhs_number: valid_nhs_number }
      expect(session[:know_nhs_number]).to eq I18n.t("coronavirus_form.questions.know_nhs_number.options.option_yes.label")
    end

    it "sets session variables" do
      post :submit, params: { nhs_number: valid_nhs_number }
      expect(session[session_key]).to eq "1101230614"
    end

    it "validates the nhs_number is required" do
      post :submit, params: {}

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template(current_template)
    end

    it "validates the nhs_number is a number" do
      post :submit, params: { nhs_number: "abc" }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template(current_template)
    end

    it "validates the nhs_number is a ten digit number" do
      post :submit, params: { nhs_number: "123" }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template(current_template)
    end

    it "validates the nhs_number is passes the checksum" do
      post :submit, params: { nhs_number: "1234567890" }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template(current_template)
    end

    it "redirects to next step for a valid NHS number" do
      post :submit, params: { nhs_number: valid_nhs_number }
      expect(response).to redirect_to(name_path)
    end

    it "redirects to check your answers if check your answers previously seen" do
      session[:check_answers_seen] = true
      post :submit, params: { nhs_number: valid_nhs_number }

      expect(response).to redirect_to(check_your_answers_path)
    end
  end
end
