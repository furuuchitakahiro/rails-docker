bundle install

sh ./utils/wait-for-it.sh db:5432 -t 30

cd <app name>
bundle install
bundle exec rake db:migrate
bundle exec rails server --port=8000 --binding=0.0.0.0
