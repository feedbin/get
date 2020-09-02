class InsensitiveHash < Hash
  def [](key)
    super _downcase(key)
  end

  def []=(key, value)
    super _downcase(key), value
  end

  protected

  def _downcase(key)
    key.respond_to?(:downcase) ? key.downcase : key
  end
end