class SSE
  def initialize(io, options = {})
    @io = io
    @options = options
  end

  def write(object, options = {})
    options.each do |k, v|
      @io.write "#{k}: #{v}\n"
    end
    @io.write "data: #{JSON.generate(object)}\n\n"
  rescue IOError
    # クライアントが切断した場合
  end

  def close
    @io.close
  rescue IOError
    # 既に閉じられている場合
  end
end
