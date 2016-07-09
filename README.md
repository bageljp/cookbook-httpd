What's ?
===============
chef で使用する apache の cookbook です。

Usage
-----
cookbook なので berkshelf で取ってきて使いましょう。

* Berksfile
```ruby
source "https://supermarket.chef.io"

cookbook "httpd", git: "https://github.com/bageljp/cookbook-httpd.git"
```

```
berks vendor
```

#### Role and Environment attributes

* sample_role.rb
```ruby
override_attributes(
  "httpd" => {
    "version" => {
      "major" => "2.4"
    },
    "user" => "apache",
    "group" => {
      "add" => "tlab-app"
    },
    "log_rotate" => "31",
    "mpm" => "prefork",
    "mod_ssl" => {
      "enable" => true,
      "link_dir" => "2014",
      "server_key" => "",
      "server_crt" =>  "",
      "chain_crt" => ""
    },
    "mod_extract_forwarded" => {
      "enable" => false
    },
    "conf" => {
      "template_dir" => "conf_" + Chef::Config[:node_name].gsub(/[0-9]*$/, '')
    }
  }
)
```

Recipes
----------

#### httpd::default
apache のインストール、ログローテーションやサービスの設定をします。

#### httpd::mods
apache の各種モジュールの設定を行います。実質 mod_ssl の設定レシピ。

#### httpd::conf
apache の各種設定ファイル用レシピ。  
ちょっと特殊で、 ``templates/default/['httpd']['conf']['template_dir']`` にある設定ファイル一式を適用します。  
こうなってる理由は案件毎にそもそも設定ファイルの数が違うので一々レシピに手を入れる必要が生じたため。


Attributes
----------

主要なやつのみ。

#### httpd::default
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
  </tr>
  <tr>
    <td><tt>['httpd']['install_flavor']</tt></td>
    <td>yum or rpm</td>
    <td>通常はyumで、rpmbuild済みのrpmを入れたい場合はrpmを使用。</td>
  </tr>
  <tr>
    <td><tt>['httpd']['link_dir']</tt></td>
    <td>string</td>
    <td>sslの鍵や証明書ファイルのシンボリックリンク先。2014、2015などssl更新タイミングで切り替えると良い。</td>
  </tr>
  <tr>
    <td><tt>['httpd']['user']</tt></td>
    <td>string</td>
    <td>apache の起動ユーザ。</td>
  </tr>
  <tr>
    <td><tt>['httpd']['group']['add']</tt></td>
    <td>array string</td>
    <td>apache の起動ユーザをグループのメンバに含める。起動ユーザとデプロイユーザが異なる場合とかに。</td>
  </tr>
</table>

