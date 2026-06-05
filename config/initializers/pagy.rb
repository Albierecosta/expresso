# frozen_string_literal: true

# Pagy 9+ ships overflow/limit handling in core; no extras needed.
Pagy::DEFAULT[:limit]    = 20
Pagy::DEFAULT[:size]     = 7
Pagy::DEFAULT[:overflow] = :last_page
