class CommunityRequestForm
  attr_reader :result

  attr_accessor :community_request

  def self.create(params)
    (form = new).create(params)
    form
  end

  def create(params)
    @community_request = CommunityRequest.new(params[:community_request])
    community_request.user = params[:user]
    ActiveRecord::Base.transaction do
      @result = @community_request.user.save && community_request.save or raise ActiveRecord::Rollback
    end
    UserMailer.community_request_created(community_request).deliver_now if result
  end
end
