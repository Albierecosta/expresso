module ApplicationHelper
  # Renders the SVG markup for a QR code encoding `url`.
  # `module_size` controls each "pixel" in CSS px (4-8 is a good range).
  # Returns html_safe SVG inline-able anywhere.
  def qr_code_svg(url, module_size: 6, color: "000", background: "fff")
    qr = RQRCode::QRCode.new(url.to_s, level: :m)
    # `standalone: false` strips both the XML declaration AND the <svg> wrapper.
    # We want only the <?xml ?> declaration gone, so render standalone and strip it.
    svg = qr.as_svg(color: color, shape_rendering: "crispEdges", module_size: module_size)
            .sub(/\A<\?xml[^?]*\?>/, "")
            .html_safe
    content_tag(:div, svg,
                style: "background:##{background};display:inline-block;padding:8px;border-radius:4px")
  end

  # Formats a BigDecimal/numeric as BRL with R$ prefix and comma separator.
  def brl(amount)
    number_to_currency(amount, unit: "R$", separator: ",", delimiter: ".", precision: 2)
  end
end
