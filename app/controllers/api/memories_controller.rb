require 'openai'

module Api
  class MemoriesController < ApplicationController
    before_action :authenticate_user!

    def my_page
      # 現在ログインしているユーザーに紐づくメモリーを取得
      if current_user
        memories = current_user.memories.order(created_at: :desc) # メモリーを作成日時の降順で取得
        render json: memories, status: :ok
      else
        render json: { error: 'Unauthorized' }, status: :unauthorized
      end
    end

    # GET /api/memories
    def index
      @memories = Memory.all.order(created_at: :desc) # 作成日時で並び替え
      render json: @memories.map { |memory|
        {
          id: memory.id,
          content: {
            inputContent: memory.content,
            transformedContent: memory.transformed_content,
            createdAt: memory.created_at
          },
          createdAt: memory.created_at,
          updatedAt: memory.updated_at
        }
      }, status: :ok
    end

    # POST /api/memories
    def create
      @memory = current_user.memories.build(memory_params)
      if @memory.save
        render json: {
          id: @memory.id,
          content: {
            inputContent: @memory.content,
            transformedContent: @memory.transformed_content,
            createdAt: @memory.created_at
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
      params.require(:memory).permit(:content)
    end
  end
end
