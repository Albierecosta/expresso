require "rails_helper"

RSpec.describe "Public::Deliveries" do
  let(:freight) { create(:freight) }
  let(:token)   { freight.public_token }
  let(:photo)   { Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/files/sample.png"), "image/png") }

  describe "GET /d/:token" do
    it "renders the data step" do
      get public_delivery_path(token: token)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(freight.code, "Confirmar Recebimento")
    end

    it "returns 404 for unknown tokens" do
      get public_delivery_path(token: "nope")
      expect(response).to have_http_status(:not_found)
    end

    it "short-circuits cancelled freights with 410" do
      freight.update!(status: :cancelled)
      get public_delivery_path(token: token)
      expect(response).to have_http_status(:gone)
      expect(response.body).to include("cancelado")
    end

    it "redirects to done if already delivered" do
      freight.create_delivery!(
        signature_svg: "<svg>", recipient_name: "M", delivered_at: Time.current,
        ip_address: "1", user_agent: "x"
      )
      freight.update!(status: :delivered)

      get public_delivery_path(token: token)
      expect(response).to redirect_to(public_delivery_done_path(token: token))
    end
  end

  describe "POST /d/:token/photo" do
    it "attaches the photo and redirects to the signature step" do
      expect {
        post public_delivery_photo_path(token: token), params: { delivery: { photo: photo } }
      }.to change(Delivery, :count).by(1)

      expect(response).to redirect_to(public_delivery_signature_path(token: token))
      expect(freight.reload.delivery.photo).to be_attached
    end
  end

  describe "GET /d/:token/signature" do
    it "redirects back to photo when no photo is attached yet" do
      get public_delivery_signature_path(token: token)
      expect(response).to redirect_to(public_delivery_photo_path(token: token))
    end

    it "renders the signature pad once the photo is attached" do
      post public_delivery_photo_path(token: token), params: { delivery: { photo: photo } }
      get public_delivery_signature_path(token: token)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("signature", "Assinatura")
    end
  end

  describe "POST /d/:token/signature (sign)" do
    before { post public_delivery_photo_path(token: token), params: { delivery: { photo: photo } } }

    it "signs the delivery, transitions the freight, and redirects to done" do
      post public_delivery_signature_path(token: token), params: {
        delivery: { signature_svg: "data:image/svg+xml;base64,xx", recipient_name: "Maria Souza" }
      }

      expect(response).to redirect_to(public_delivery_done_path(token: token))
      expect(freight.reload).to be_delivered
      expect(freight.delivery.recipient_name).to eq("Maria Souza")
    end

    it "re-renders the signature page when payload is missing" do
      post public_delivery_signature_path(token: token), params: {
        delivery: { signature_svg: "", recipient_name: "" }
      }
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "GET /d/:token/done" do
    it "redirects back to the start when no delivery exists" do
      get public_delivery_done_path(token: token)
      expect(response).to redirect_to(public_delivery_path(token: token))
    end

    it "renders the confirmation when the delivery is signed" do
      delivery = freight.create_delivery!
      delivery.sign(signature_svg: "<svg>", recipient_name: "Maria",
                    ip_address: "1.1.1.1", user_agent: "RSpec")

      get public_delivery_done_path(token: token)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Recebimento Confirmado", "Maria")
    end
  end
end
