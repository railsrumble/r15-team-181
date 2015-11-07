class User < ActiveRecord::Base
  def self.from_omniauth auth
    where(provider: auth.provider, uid: auth.uid).first_or_initialize.tap do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.name = auth.info.name
      user.oauth_token = auth.credentials.token
      user.oauth_expires_at = Time.at(auth.credentials.expires_at)
      user.save!
    end
  end

  def facebook
    @facebook ||= Koala::Facebook::API.new(oauth_token)
    block_given? ? yield(@facebook) : @facebook
  rescue Koala::Facebook::APIError
    logger.info e.to_s
    nil
  end

  def friends_count
    facebook do |fb|
      friends = fb.get_connection("me", "invitable_friends")
      count = 0
      loop do
        count += friends.size
        friends = friends.next_page
        break if friends.nil?
      end
      count
    end
  end

  def friends_names
    list = []
    facebook do |fb|
      friends = fb.get_connection("me", "invitable_friends")
      loop do
        list += friends.map{ |x| x["name"] }
        friends = friends.next_page
        break if friends.nil?
      end
    end
    list
  end
end
