# frozen_string_literal: true

source "https://rubygems.org"

ruby '2.7.3'

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

gem 'rspec'
gem 'coderay'
gem 'rack-test'
gem 'sinatra'
gem 'sequel'
gem 'sqlite3'

group :development, :test do
  gem 'rubocop', '~> 1.20'
  gem 'pry'
end

group :test do
  gem 'database_cleaner-sequel'
end


gem "puma", "~> 5.5"
