# rails-docker

これは Ruby on Rails ( 以降 Rails ) と PostgreSQL の開発環境構築の Docker Compose テンプレートです。

プロゲートの Rails コースを修了したぐらいの方が開発環境構築をスムーズにできるようにするのが目的です。

一通りの手順は[チュートリアル](#user-content-チュートリアル)に書いてあります。Rails 初心者や Docker 初心者の方はチュートリアルを一度試してみることをおすすめします。

## 必要なもの

各自インストールして置いてください。

- git
- Docker
- Docker Compose

## 使い方

### 使い方の流れ

1. [Rails アプリ作成](#user-content-rails-アプリを作成したい)
2. **rails-docker/app/startapp.dev.sh** の `<app name>` を作成した Rails アプリ名に変更
3. [データベースの初期化](#user-content-データベースをすべて初期化したい)
4. `docker-compose up` を実行

### Rails アプリを作成したい

**rails-docker/app** ディレクトリで Ruby コンテナを起動します。

`docker run --rm -it -v "$(pwd):/tmp" ruby:2.5.1 bash`

マウントしたディレクトリ ( /tmp ) に移動します。

`cd /tmp`

移動したら Rails をインストールします。

`bundle install`

インストールが完了したら Rails アプリを作成します。

`rails new <app name> --database=postgresql`

### rails コマンドや rake コマンドを実行したい

Docker コンテナが動いている状態で

 `docker-compose exec app bash`

これで Rails が動いているコンテナを操作できます。

`rails generate model ...`

や

```bash
cd <app name>
bundle exec rake db:migrate
```

のようにいつも通りの rails コマンド等を実行できます。

### データベースをすべて初期化したい

Docker コンテナを終了させておきます。

**rails-docker** ディレクトリで以下コマンドを実行して削除します。( **rails-docker/db/datadir/** ディレクトリの中身が空っぽであれば、このコマンドは必要ありません )

`rm -rf db/datadir/*`

続いて、データベースの初期化をします。

`docker-compose up db`

しばらくしたら「 **データベースシステムの接続受け付け準備が整いました。** 」のような表示がされるので `Control + C` のキーの同時押しで終了します。

これで初期化完了です。

### データベースのユーザーやパスワード等を変更したい

**rails-docker/docker-compose.yml** ファイル内にある

- POSTGRES_USER
- POSTGRES_PASSWORD
- POSTGRES_DB

を変更して、Rails アプリ内の **config/database.yml** も同じように以下の部分を変更します。

- username
- password
- database

変更した際はデータベースの初期化が必要になります。

### Rails の起動ポートを変更したい

**rails-docker/docker-compose.yml** ファイル内にある services -> app -> ports の項目の

`"8000:8000"`

の部分を変更します。( 例えば `"3000:3000"` )

更に、起動スクリプト ( **rails-docker/app/utils/startapp.dev.sh** ) の

`bundle exec rails server --port=8000 --binding=0.0.0.0`

の `--port=8000` を `--port=3000` に変更します。

## チュートリアル

まず、必要なものが揃っていなければインストールをしてください。

必要なものをインストールしたらこのリポジトリをクローン ( ダウンロード ) します。

`git clone git@github.com:furuuchitakahiro/rails-docker.git`

このコマンドでエラーが出る方は

`git clone https://github.com/furuuchitakahiro/rails-docker.git`

でクローンしてください。

クローンが完了したら、rails-docker ディレクトリに移動します。

`cd rails-docker`

移動したら Ruby の Docker イメージをダウンロードします。

`docker pull ruby:2.5.1`

ダウンロードが完了したら確認してみましょう。

`docker images`

このコマンドで

```
REPOSITORY                                      TAG                 IMAGE ID            CREATED             SIZE
ruby                                            2.5.1               34d1c6024e99        6 weeks ago         869MB
```

のような表示があれば大丈夫です。

続いて Rails アプリを作成します。

まず、 app ディレクトリに移動します。

`cd app`

Rails アプリ作成用コンテナを起動します。

`docker run --rm -it -v "$(pwd):/tmp" ruby:2.5.1 bash`

このコマンドを叩くと Ruby が動く Docker コンテナが起動し、bash ( ターミナル ) で操作できるようになります。

プロゲートの Rails コース中の画面にあるターミナルのタブと同じです。

まずは、先程のコマンドで指定したマウント先のディレクトリに移動します。

`cd /tmp`

移動したら必要なものをインストールします。

`bundle install`

Rails アプリを作成します。

ここでは **sample** の名前でアプリを作成します。

`rails new sample --database=postgresql`

これで Rails アプリ作成は完了です。

完了したら Ruby の Docker コンテナを終了します。

`exit`

続いてデータベースの設定をします。

データベースの設定は **sample/config/database.yml** ファイルです。

以下は database.yml ファイルの設定です。

```yaml
default: &default
  adapter: postgresql
  encoding: unicode
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>

development:
  <<: *default
  host: db
  database: dev_rails_db
  username: dev_rails_user
  password: dev_rails_password
test:
  <<: *default
  host: db
  database: dev_rails_db
  username: dev_rails_user
  password: dev_rails_password
production:
  <<: *default
  database: sample_production
  username: sample
  password: <%= ENV['SAMPLE_DATABASE_PASSWORD'] %>
```

設定したら起動スクリプトを修正します。

起動スクリプトは **rails-docker/app/utils/startapp.dev.sh** ファイルです。

```bash
bundle install

sh ./utils/wait-for-it.sh db:5432 -t 30

cd sample
bundle install
bundle exec rake db:migrate
bundle exec rails server --port=8000 --binding=0.0.0.0
```

変更点は `cd <app name>` を `cd sample` にした点です。

最後の仕上げです。

まずは、Docker のイメージをビルドします。

`docker-compose build`

完了したらデータベースコンテナを初期化します。

`docker-compose up db`

「 **データベースシステムの接続受け付け準備が整いました。** 」の様な表示が出たら `Control + C` のキーを同時に押して終了させます。

これで準備が整いました。

それでは起動してみましょう。

`docker-compose up`

この様な文字が表示されたら起動成功です。 :tada::tada::tada:

```
app_1  | => Booting Puma
app_1  | => Rails 5.2.1 application starting in development
app_1  | => Run `rails server -h` for more startup options
app_1  | Puma starting in single mode...
app_1  | * Version 3.12.0 (ruby 2.5.1-p57), codename: Llamas in Pajamas
app_1  | * Min threads: 5, max threads: 5
app_1  | * Environment: development
app_1  | * Listening on tcp://0.0.0.0:8000
app_1  | Use Ctrl-C to stop
```

確認もしてみましょう。

http://localhost:8000

Rails の画面が表示されていれば大丈夫です。

以上です。
