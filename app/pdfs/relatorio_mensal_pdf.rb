class RelatorioMensalPdf < BasePdf
  def initialize(client:, date:, freights:)
    @client   = client
    @date     = date
    @freights = freights.includes(:recipient, delivery: { photo_attachment: :blob })
  end

  private

  attr_reader :client, :date, :freights

  def build(pdf)
    header(pdf, "Relatório Mensal")

    summary(pdf)
    pdf.move_down 12
    table(pdf)
  end

  def summary(pdf)
    label_value = ->(label, value) { [ [ { content: label, font_style: :bold }, value ] ] }

    rows = []
    rows += label_value.call("Cliente", client&.name || "Todos os clientes")
    rows += label_value.call("Período", "#{I18n.l(date.beginning_of_month, format: :short)} até #{I18n.l(date.end_of_month, format: :short)}")

    pdf.table(rows,
              cell_style: { borders: [], padding: [ 2, 6 ], size: 10 },
              column_widths: { 0 => 80 })
  end

  def table(pdf)
    headers = [ "Data", "Código do Frete", "Destinatário", "Valor", "Recebido por" ]
    rows = freights.map do |f|
      delivered = f.delivery&.delivered_at&.to_date || f.created_at.to_date
      [
        I18n.l(delivered, format: :short),
        f.code,
        f.recipient.name,
        format_currency(f.amount),
        f.delivery&.recipient_name.to_s
      ]
    end

    rows << [
      { content: "TOTAL", colspan: 3, font_style: :bold, align: :right },
      { content: format_currency(freights.sum(:amount)), font_style: :bold, text_color: "059669" },
      ""
    ]

    pdf.table([ headers ] + rows,
              header: true,
              row_colors: %w[FFFFFF F9FAFB],
              cell_style: { size: 9, padding: [ 5, 6 ], borders: %i[bottom] }) do
      cells.style { |c| c.borders = %i[bottom] }
      row(0).style(background_color: "F3F4F6", font_style: :bold, size: 8)
    end
  end

  def format_currency(amount)
    ActionController::Base.helpers.number_to_currency(amount,
      unit: "R$", separator: ",", delimiter: ".", precision: 2)
  end
end
