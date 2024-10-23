module Api
  class MemoriesController < Api::ApplicationController
    before_action :authenticate_user!, except: [:index] # index以外で認証を要求
    skip_before_action :authenticate_user!, only: [:index]  # indexアクションでのみ認証をスキップ

    def my_page
      if current_user
        memories = current_user.memories.order(created_at: :desc)
        render json: memories, status: :ok
      else
        render json: { error: 'Unauthorized' }, status: :unauthorized
      end
    end

    # GET /api/memories
    def index
      @memories = Memory.all.order(created_at: :desc)
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

    private

    def memory_params
      params.require(:memory).permit(:content)
    end
  end
end
