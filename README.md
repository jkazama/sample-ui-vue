sample-ui-vue
---

### はじめに

[BootStrap](http://getbootstrap.com/) / [Vue.js](http://jp.vuejs.org/) を元にしたプロジェクトWebリソース(HTML/CSS/JS)です。SPA(Single Page Application)モデルを前提としています。  

サンプル確認用のAPIサーバとして[sample-boot-hibernate](https://github.com/jkazama/sample-boot-hibernate)を期待します。

> 現在作成中で、リファクタリングを継続しています。（jquery依存の外し、Webpackのビルド時間軽減等)

#### ビルド/テスト稼働環境構築

ビルドは [Node.js](http://nodejs.jp/) + [Webpack](https://webpack.github.io/) + [Gulp](http://gulpjs.com/) で行います。以下の手順でインストールしてください。

1. Node.js の[公式サイト](http://nodejs.jp/)からインストーラをダウンロードしてインストール。
1. 「`npm install -g gulp`」を実行してGulpをインストール。
    - Macユーザは「`sudo npm install -g gulp`」で。
1. コンソールで本ディレクトリ直下へ移動後、「`npm install`」を実行してGulpライブラリをインストール。
    - Windowsユーザは「npm install --msvs_version=2013」。理由は後述
1. 「`gulp bower`」を実行してアプリケーションで利用する関連ライブラリをプリインストール。

---

標準で利用想定の[BrowserSync](http://www.browsersync.io/)はLiveReloadよりも同期が早く開発生産性に大きく寄与しますが、Windowsユーザの場合は[Python2.7](https://www.python.org/)と[Visual Studio 2013 Update N](https://www.visualstudio.com/downloads/download-visual-studio-vs)のインストールが必須となります。  
*※`Express 2013 for Desktop`を推奨します。(手元で試したところ`Community 2015`では正しく動きませんでした)*

### 動作確認

動作確認は以下の手順で行ってください。

1. cloneした[sample-boot-hibernate](https://github.com/jkazama/sample-boot-hibernate)を起動する。
    - 起動方法は該当サイトの解説を参照
    - application.ymlの`extension.security.auth.enabled`をtrueにして起動すればログイン機能の確認も可能
1. コンソールで本ディレクトリ直下へ移動し、「`gulp`」を実行
    - 確認用のブラウザが自動的に起動する。うまく起動しなかったときは「http://localhost:3000」へアクセス
    - 画面が白く表示されてしまう時はブラウザの更新を押してみてください

### 開発の流れ

基本的にAltリソース(.jade/.sass/.coffee[.vue])をWebリソース(.html/.css/.js)へGulpでリアルタイム変換させながら開発をしていきます。
動作確認はGulpで独自にWebサーバを立ち上げた後、ブラウザ上で行います。  

#### Altリソースの解説

- [Jade](http://jade-lang.com/)
- [Sass](http://sass-lang.com/)
- [CoffeeScript](http://coffeescript.org/)

*※「Sass SCSS」でなく「Sass」を利用しているのは単純にインデント + 閉じ無しで統一したかったためです。*

#### Altリソースの変更監視 / Webサーバ起動

+ コンソールで本ディレクトリ直下へ移動し、「`gulp`」を実行

### TODO

- JQuery依存をできる限り減らす
    - 減らせることができれば、、
- bower依存をできる限り減らす
    - package.jsonへできるだけ寄せたい
- コメントリファクタ
