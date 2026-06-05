require "rails_helper"

RSpec.describe ComprovantePdf do
  let(:freight) { create(:freight) }

  before do
    delivery = freight.create_delivery!
    delivery.sign(signature_svg: "data:image/svg+xml;base64,PHN2Zy8+",
                  recipient_name: "Maria Souza",
                  ip_address: "127.0.0.1", user_agent: "RSpec")
  end

  it "produces a non-empty PDF" do
    bytes = described_class.new(freight.reload).render
    expect(bytes).to be_a(String)
    expect(bytes).to start_with("%PDF")
  end
end
