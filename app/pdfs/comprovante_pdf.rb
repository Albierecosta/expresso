class ComprovantePdf < BasePdf
  def initialize(freight)
    @freight  = freight
    @delivery = freight.delivery
  end

  private

  attr_reader :freight, :delivery

  def build(pdf)
    header(pdf, "Comprovante de Entrega")

    info_block(pdf)
    pdf.move_down 16
    address_block(pdf)
    pdf.move_down 16
    delivery_block(pdf) if delivery&.delivered_at
    pdf.move_down 16
    footer(pdf)
  end

  def info_block(pdf)
    pdf.table([
                [ "Código do Frete", freight.code, "Data e hora",
                  delivery&.delivered_at ? I18n.l(delivery.delivered_at, format: :long) : "—" ],
                [ "Cliente", freight.client.name, "Destinatário", freight.recipient.name ],
                [ "Valor do Frete", format_currency(freight.amount), "Nº do Pedido",
                  freight.order_number.presence || "—" ]
              ],
              cell_style: { borders: [], padding: [ 4, 6 ], size: 10 },
              column_widths: { 0 => 110, 2 => 110 })
  end

  def address_block(pdf)
    pdf.text "Endereço", style: :bold, size: 10
    pdf.text freight.address.to_s, size: 10
  end

  def delivery_block(pdf)
    pdf.text "Comprovação", style: :bold, size: 11
    pdf.move_down 6

    pdf.text "Recebido por: #{delivery.recipient_name}", size: 10
    pdf.move_down 8

    embed_photo(pdf)     if delivery.photo.attached?
    embed_signature(pdf) if delivery.signature_svg.to_s.start_with?("data:image/")
  end

  def embed_photo(pdf)
    blob = delivery.photo.download
    pdf.text "Foto do recebimento:", size: 9, style: :italic
    pdf.image StringIO.new(blob), width: 200, position: :left
    pdf.move_down 8
  rescue StandardError
    # Photo missing/corrupted/unsupported — skip rather than fail the whole PDF.
    # The receipt is still useful with the signature + audit data alone.
  end

  def embed_signature(pdf)
    pdf.text "Assinatura:", size: 9, style: :italic
    pdf.text delivery.recipient_name, style: :italic, size: 12, align: :left
  end

  def footer(pdf)
    pdf.move_down 24
    pdf.text "Recebimento confirmado via sistema.",
             size: 8, color: "999999", align: :center
  end

  def format_currency(amount)
    ActionController::Base.helpers.number_to_currency(amount,
      unit: "R$", separator: ",", delimiter: ".", precision: 2)
  end
end
