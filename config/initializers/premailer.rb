Premailer::Rails.config.merge!(
  :generate_text_part => false,
  :verbose => Rails.env != "production"
)
