# docker-konomitv-acme
[KonomiTV](https://github.com/tsukumijima/KonomiTV) で Let's Encrypt 等の ACME 対応認証局の証明書を使うためのコンテナイメージ

## 概要
本リポジトリが提供するのは、独自ドメインの証明書の自動発行・更新機能がついた KonomiTV のコンテナイメージです。

[KonomiTV](https://github.com/tsukumijima/KonomiTV) では [Akebi](https://github.com/tsukumijima/Akebi) のおかげで、自分で証明書を発行しなくても https://192-168-0-10.local.konomi.tv:7000/ のような URL で HTTPS アクセスができます。特にこだわりがなければこれで問題ないのですが、個人的に自分のドメイン名で KonomiTV にアクセスしたいと思ったため本イメージを作成しました。


## 環境変数
ACME クライアントが必要とする値を環境変数として渡すことができます。

| 環境変数                  | 説明                                                                        | 必須 |
| ------------------------- | --------------------------------------------------------------------------- | ---- |
| `CERT_DOMAIN`             | 証明書を発行するドメイン                                                    | ✅    |
| `LEGO_EMAIL`              | 自分のメールアドレス                                                        | ✅    |
| `LEGO_DNS_PROVIDER`       | [LEGO の DNS プロバイダ](https://go-acme.github.io/lego/dns/#dns-providers) | ✅    |
| (DNSプロバイダの認証情報) | `LEGO_DNS_PROVIDER` で指定した DNS プロバイダに応じた環境変数と値を設定     | ✅    |
| `LEGO_SERVER`             | ACME サーバー（デフォルト値は Let's Encrypt）                               |      |
| `LEGO_EAB`                | EAB が必要かどうかのフラグ（任意の値をセットすると EAB が有効になる）       |      |
| `LEGO_EAB_KID`            | EAB の キー ID                                                              |      |
| `LEGO_EAB_HMAC`           | EAB の HMAC キー                                                            |      |

## Docker Compose で動かす
`compose.yml` の例を `example/` 以下に配置してあります。Let's Encrypt 版と ZeroSSL 版の 2 種類を用意しています。実行前に `config.yaml`（KonomiTV の設定ファイル）を編集して、Mirakurun の URL を修正する必要があります。
