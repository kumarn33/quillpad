class SearchEngine
  # Search engine searches posts in a user scope.
  # The search is not on all the public posts.

  def self.search(user, query, signed_in = false, page = 1, options = {})
    new(
      user,
      query,
      signed_in,
      page,
      options
    ).perform
  end

  def initialize(user, query, signed_in, page, options = {})
    raise InvalidSearchError if user.blank?

    @user  = user
    @query = query.to_s.strip
    @page  = page
    @user_signed_in = signed_in
    @options = default_options.merge(options)
  end

  def perform
    cursor = @user
      .posts
      .order('id DESC')
      .page(@page)

    if @query.present?
      cursor = cursor.search_for(@query)
    end

    if Post::KINDS.include?(@options[:kind])
      cursor = cursor.where(kind: @options[:kind])
    end

    if !@user_signed_in
      cursor = cursor.published
    end

    cursor
  end

  def default_options
    {
      kind: 'default'
    }.with_indifferent_access
  end
end