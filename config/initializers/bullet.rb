if defined?(Bullet) && Rails.env.development?
  Rails.application.config.after_initialize do
    Bullet.enable        = true
    Bullet.alert         = false
    Bullet.bullet_logger = true
    Bullet.console       = true
    Bullet.add_footer    = true

    Bullet.raise         = false # set true in CI if you want hard failures
  end
end
