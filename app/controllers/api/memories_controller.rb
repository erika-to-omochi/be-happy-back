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
            name: memory.name || memory.user&.name || 'ゲスト'
          },
          createdAt: memory.created_at,
          updatedAt: memory.updated_at
        }
      }, status: :ok
    end

    def create
      if current_user.is_a?(User)
        @memory = current_user.memories.build(memory_params)
      else
        name = memory_params[:name] || 'ゲスト'
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
            name: @memory.name || (current_user.is_a?(User) ? current_user.name : 'ゲスト')
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
      @memory = if current_user.is_a?(User)
        Memory.find_by(id: params[:id], user_id: current_user.id)
      else
        Memory.find_by(id: params[:id], guest_user_id: current_user.id)
      end

      if @memory.nil?
        render json: { error: '他の人の記憶は変換できません' }, status: :forbidden
        return
      end

      client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])
      if @memory.transformed_content.present?
        render json: { error: 'Transformed content is missing' }, status: :unprocessable_entity
        return
      end

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

      if response['choices'] && response['choices'][0]['message']['content']
        # 変換されたコンテンツを保存
        @memory.transformed_content = response['choices'][0]['message']['content']

        if @memory.save
          render json: {
            id: @memory.id,
            content: {
              inputContent: @memory.content,
              transformedContent: @memory.transformed_content,
              createdAt: @memory.created_at
            },
            user: {
              name: @memory.name || @memory.user&.name || 'ゲスト'
            },
            createdAt: @memory.created_at,
            updatedAt: @memory.updated_at
          }, status: :ok
        else
          render json: @memory.errors, status: :unprocessable_entity
        end
      else
        render json: { error: 'OpenAI APIの呼び出しに失敗しました。' }, status: :internal_server_error
      end
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'Memory not found' }, status: :not_found
    rescue StandardError => e
      render json: { error: 'Internal Server Error' }, status: :internal_server_error
    end

    private

    def memory_params
      params.require(:memory).permit(:content, :name, :user_id)
    end
  end
end
