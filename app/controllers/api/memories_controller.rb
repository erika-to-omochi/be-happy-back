module Api
  class MemoriesController < Api::ApplicationController
    before_action :authenticate_user!, except: [:index]

    def my_page
      if current_user
        memories = current_user.memories.includes(:user).order(created_at: :desc)
        render json: memories.to_json(include: :user), status: :ok
      else
        render json: { error: 'Unauthorized' }, status: :unauthorized
      end
    end

    def index
      @memories = Memory.includes(:user).order(created_at: :desc) # userも一緒にロード
      render json: @memories.map { |memory|
        {
          id: memory.id,
          content: {
            inputContent: memory.content,
            transformedContent: memory.transformed_content,
            createdAt: memory.created_at
          },
          user: {
            name: memory.user&.name || memory.name || 'ゲスト' # ログインしている場合はユーザー名、いない場合は手動で入力された名前か「ゲスト」
          },
          createdAt: memory.created_at,
          updatedAt: memory.updated_at
        }
      }, status: :ok
    end

    def create
      Rails.logger.info "Current user: #{current_user.inspect}"
      name = current_user&.name || memory_params[:name] || 'ゲスト'

      if current_user
        @memory = current_user.memories.build(memory_params) # 認証済みユーザー
      else
        @memory = Memory.new(memory_params.merge(name: name)) # ゲストユーザーの場合
      end

      if @memory.save
        render json: {
          id: @memory.id,
          content: {
            inputContent: @memory.content,
            transformedContent: @memory.transformed_content,
            createdAt: @memory.created_at
          },
          user: {
            name: name # ユーザーがいない場合は手動で入力された名前を使用
          },
          createdAt: @memory.created_at,
          updatedAt: @memory.updated_at
        }, status: :created
      else
        render json: @memory.errors, status: :unprocessable_entity
      end
    end

    # POST /api/memories/:id/transform
    def transform
      @memory = Memory.find(params[:id])
      client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])

      response = client.chat(
        parameters: {
          model: "gpt-3.5-turbo",
          messages: [
            { role: "system", content: "あなたはユーザーの嫌な記憶をポジティブに変換するアシスタントです。" },
            { role: "user", content: @memory.content }
          ],
          max_tokens: 150,
          temperature: 0.7
        }
      )

      Rails.logger.info "OpenAI Response: #{response.inspect}" # デバッグ用ログ

      if response['choices'] && response['choices'][0]['message']['content']
        @memory.transformed_content = response['choices'][0]['message']['content']
        Rails.logger.info "Transformed Content: #{@memory.transformed_content}" # デバッグ用ログ
        if @memory.save
          render json: {
            id: @memory.id,
            content: {
              inputContent: @memory.content,
              transformedContent: @memory.transformed_content,
              createdAt: @memory.created_at
            },
            user: {
              name: @memory.user&.name || @memory.name || 'ゲスト' # ユーザーがいない場合は「ゲスト」または手動で入力された名前
            },
            createdAt: @memory.created_at,
            updatedAt: @memory.updated_at
          }, status: :ok
        else
          render json: @memory.errors, status: :unprocessable_entity
        end
      else
        Rails.logger.error "OpenAI API call failed or returned unexpected format."
        render json: { error: 'OpenAI APIの呼び出しに失敗しました。' }, status: :internal_server_error
      end
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'Memory not found' }, status: :not_found
    rescue StandardError => e
      Rails.logger.error "Transform Error: #{e.message}"
      render json: { error: 'Internal Server Error' }, status: :internal_server_error
    end

    private

    def memory_params
      params.require(:memory).permit(:content, :name, :user_id)
    end
  end
end
