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
      @memories = Memory.includes(:user).order(created_at: :desc)
      render json: @memories.map { |memory|
        {
          id: memory.id,
          content: {
            inputContent: memory.content,
            transformedContent: memory.transformed_content,
            createdAt: memory.created_at
          },
          user: {
            name: memory.user&.name || memory.name || 'ゲスト'
          },
          createdAt: memory.created_at,
          updatedAt: memory.updated_at
        }
      }, status: :ok
    end

    def create
      Rails.logger.info "Current user: #{current_user.inspect}"
      name = current_user.is_a?(User) ? current_user.name : memory_params[:name] || 'ゲスト'
      if current_user.is_a?(User)
        # 認証済みユーザーの場合は user_id を使用
        @memory = current_user.memories.build(memory_params)
      else
        # ゲストユーザーの場合は guest_user_id を使用
        @memory = Memory.new(memory_params.merge(name: name, guest_user_id: current_user.id))
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
            name: name
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
      Rails.logger.info("Received params: #{params.inspect}")
      Rails.logger.info("Current user: #{current_user.inspect}")

      # ユーザーが認証済みかどうかに基づいてメモリーを取得
      @memory = if current_user.is_a?(User)
        Memory.find_by(id: params[:id], user_id: current_user.id)
      else
        Memory.find_by(id: params[:id], guest_user_id: current_user.id)
      end

      if @memory.nil?
        Rails.logger.error("Memory not found for ID: #{params[:id]}, User: #{current_user.inspect}")
        render json: { error: '他の人の記憶は変換できません' }, status: :forbidden
        return
      end

      # OpenAI API を使って変換処理を行う
      client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])

      # transformed_content が既に存在するか確認
      if @memory.transformed_content.present?
        render json: { error: 'Transformed content is missing' }, status: :unprocessable_entity
        return
      end

      # OpenAI API 呼び出し
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

      Rails.logger.info "OpenAI Response: #{response.inspect}"

      if response['choices'] && response['choices'][0]['message']['content']
        # 変換されたコンテンツを保存
        @memory.transformed_content = response['choices'][0]['message']['content']
        Rails.logger.info "Transformed Content: #{@memory.transformed_content}"

        if @memory.save
          render json: {
            id: @memory.id,
            content: {
              inputContent: @memory.content,
              transformedContent: @memory.transformed_content,
              createdAt: @memory.created_at
            },
            user: {
              name: @memory.user&.name || @memory.name || 'ゲスト'
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
