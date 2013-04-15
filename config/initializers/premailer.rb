Premailer::Rails.config.merge!(
  :generate_text_part => false,
  :warn_level => Premailer::Warnings::RISKY,
  :verbose => Rails.env == "development"
)
