class BlobWithExtension < SimpleDelegator
  def key
    object.key + File.extname(object.filename.to_s)
  end

  private

  def object
    __getobj__
  end
end
