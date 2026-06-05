# Prawn's built-in AFM fonts have limited UTF-8 support but cover all the
# pt-BR characters our receipts and reports use. Silence the noisy warning.
Prawn::Fonts::AFM.hide_m17n_warning = true
