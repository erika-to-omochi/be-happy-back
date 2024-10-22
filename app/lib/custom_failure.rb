class CustomFailure < Devise::FailureApp
  def respond
    # JSONでのリクエストの場合、常にエラーレスポンスを返す
    if request.format.json?
      json_error_response
    else
      json_error_response # 強制的にJSONを返す
    end
  end

  def json_error_response
    self.status = 401
    self.content_type = 'application/json'
    self.response_body = { error: 'Unauthorized' }.to_json
  end

  # セッションに書き込むリダイレクト処理を無効化
  def store_location!
    # 何もしない
  end
end
