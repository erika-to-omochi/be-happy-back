require 'openai'

class MemoriesController < ApplicationController
  def create
    @memory = Memory.new(memory_params)
    if @memory.save
      render json: @memory, status: :created
    else
      render json: @memory.errors, status: :unprocessable_entity
    end
  end

  # openAIを使ったポジティブ変換
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

    if response['choices'] && response['choices'][0]['message']['content']
      @memory.transformed_content = response['choices'][0]['message']['content']
      if @memory.save
        render json: @memory, status: :ok
      else
        render json: @memory.errors, status: :unprocessable_entity
      end
    else
      render json: { error: 'OpenAI APIの呼び出しに失敗しました。' }, status: :internal_server_error
    end
  end

  private

  def memory_params
    params.require(:memory).permit(:content)
  end
end
