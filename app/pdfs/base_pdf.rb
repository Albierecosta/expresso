# Base for every Prawn PDF generator. Subclasses implement `build(pdf)`
# and call `.render` to get bytes back. Keeping the public surface
# minimal here so every PDF has the same `Klass.new(...).render` shape.
class BasePdf
  def render
    Prawn::Document.new(page_size: "A4", margin: 36) do |pdf|
      build(pdf)
    end.render
  end

  private

  def build(pdf)
    raise NotImplementedError, "#{self.class.name} must implement #build(pdf)"
  end

  def company = @company ||= Company.current

  # Renders the standard header (company name + CNPJ on the right) used
  # by both the receipt and the monthly report.
  def header(pdf, title)
    pdf.bounding_box([ 0, pdf.cursor ], width: pdf.bounds.width, height: 60) do
      pdf.text title, size: 16, style: :bold
      pdf.text company.name, size: 10
    end

    pdf.bounding_box([ pdf.bounds.width - 200, pdf.bounds.top ], width: 200, height: 60) do
      pdf.text company.legal_name.to_s, size: 9, align: :right
      pdf.text "CNPJ: #{company.cnpj}",  size: 9, align: :right if company.cnpj.present?
      pdf.text company.email.to_s,       size: 9, align: :right if company.email.present?
      pdf.text company.phone.to_s,       size: 9, align: :right if company.phone.present?
    end

    pdf.stroke_horizontal_rule
    pdf.move_down 12
  end
end
