module Xapi
  module Routes
    class User < Core
      before do
        require_key
      end

      def something_went_wrong
        "Something went wrong, and it's not clear what it was. Please post an issue on GitHub so we can figure it out! https://github.com/exercism/exercism.io/issues"
      end

      helpers do
        def forward_errors
          begin
            yield
          rescue Xapi::ApiError => e
            halt 400, {error: e.message}.to_json
          rescue Exception => e
            halt 500, {error: something_went_wrong}.to_json
          end
        end
      end

      get '/exercises' do
        exercises = forward_errors do
          Xapi::Homework.new(params[:key]).exercises
        end
        pg :exercises, locals: {exercises: exercises}
      end

      get '/exercises/restore' do
        exercises = forward_errors do
          Xapi::Backup.restore(params[:key])
        end
        pg :exercises, locals: {exercises: exercises}
      end

      get '/exercises/:language' do |language|
        exercises = forward_errors do
          Xapi::Homework.new(params[:key]).exercises_in(language)
        end
        pg :exercises, locals: {exercises: exercises}
      end
    end
  end
end
