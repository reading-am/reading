module MailPipe

  def self.class_to_letter obj
    case obj
    when User
      'u'
    when Comment
      'c'
    end
  end

  def self.letter_to_class letter
    case letter
    when 'u'
      User
    when 'c'
      Comment
    end
  end

  def self.encode_mail_recipient action, user, subject
    type = class_to_letter(subject)

    hash = Digest::SHA1.hexdigest("#{type}#{subject.id}#{user.token}")
    "#{action}+#{type}-#{subject.id}-#{hash}-#{user.id}@mailman.#{ROOT_DOMAIN}"
  end

  def self.decode_mail_recipient recipient
    bits = recipient.match(/.*\+(.*)@/)[1].split('-')

    hash = bits[2]
    user = User.find(bits[3])

    if Digest::SHA1.hexdigest(bits[0]+bits[1]+user.token) == hash
      {
        :user => user,
        :subject => letter_to_class(bits[0]).find(bits[1])
      }
    else
      false
    end
  end

end
