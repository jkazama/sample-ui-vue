sample-ui-vue
---

### はじめに

[BootStrap](http://getbootstrap.com/) / [Vue.js](http://jp.vuejs.org/) を元にしたプロジェクトWebリソース(HTML/CSS/JS)です。  

旧来型のアプローチ(ページを細かく分割して、JSファイルは最低限しか束ねない)で実装しています。  
*SPAではなく、モジュールベースのアーキテクチャなども利用していない。*

> 現在作成中で、これからリファクタリングしていきます。（最終的にモジュール管理 + componentを用いた組み立てベースにする予定）

#### ビルド環境構築

ビルドは Node.js + Gulp で行います。以下の手順でインストールしてください。

1. Node.js の[公式サイト](http://nodejs.jp/)からインストーラをダウンロードしてインストール。
1. 「`npm install -g gulp`」を実行して[Gulp](http://gulpjs.com/)をインストール。
    - Macユーザは「`sudo npm install -g gulp`」で。
1. コンソールで本ディレクトリ直下へ移動後、「`npm install`」を実行してGulpライブラリをインストール。
    - Windowsユーザは「npm install --msvs_version=2013」。理由は後述
1. 「`gulp bower`」を実行してアプリケーションで利用する関連ライブラリをプリインストール。

---

標準で利用想定の[BrowserSync](http://www.browsersync.io/)はLiveReloadよりも同期が早く開発生産性に大きく寄与しますが、Windowsユーザの場合は[Python2.7](https://www.python.org/)と[Visual Studio 2013 Update N](https://www.visualstudio.com/downloads/download-visual-studio-vs)のインストールが必須となります。  
*※`Express 2013 for Desktop`を推奨します。(手元で試したところ`Community 2015`では正しく動きませんでした)*

### 開発の流れ

基本的にAltリソース(.jade/.sass/.coffee)をWebリソース(.html/.css/.js)へGulpでリアルタイム変換させながら開発をしていきます。
動作確認はGulpで独自にWebサーバを立ち上げた後、ブラウザ上で行います。  

#### Altリソースの解説

- [Jade](http://jade-lang.com/)
- [Sass](http://sass-lang.com/)
- [CoffeeScript](http://coffeescript.org/)

*※「Sass SCSS」でなく「Sass」を利用しているのは単純にインデント + 閉じ無しで統一したかったためです。*

#### Altリソースの変更監視 / Webサーバ起動

+ コンソールで本ディレクトリ(web)直下へ移動し、「`gulp`」を実行

