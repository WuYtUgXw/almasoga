#!/bin/bash

# カスタムカラーとフォントサイズ
red='\033[1;31m'
green='\033[1;32m'
yellow='\033[1;33m'
yellow_light='\033[2;36m'
plain='\033[0m'

# /etc/soga フォルダの存在を確認
if [ -d /etc/soga ]; then 
    echo -e "${green}/etc/soga フォルダは既に存在しています。Sogaのインストールをスキップします。${plain}"
else
    # システムの種類を確認
    if [ -f /etc/redhat-release ]; then
        # CentOS
        echo -e "${yellow}CentOS システムを検出しました${plain}"
        # wget の存在を確認
        if command -v wget &> /dev/null; then
            echo -e "${green}システムには wget がインストールされています${plain}"
        else
            # wget をインストール
            echo -e "${green}wget がインストールされていません。インストールを開始します${plain}"
            yum install wget -y
            if [ $? -eq 0 ]; then
                echo -e "${green}wget のインストールが成功しました${plain}"
            else
                echo -e "${red}wget のインストールに失敗しました${plain}"
                exit 1
            fi
        fi
    elif [ -f /etc/debian_version ]; then
        # Debian
        echo -e "${yellow}Debian システムを検出しました${plain}"
        # wget の存在を確認
        if command -v wget &> /dev/null; then
            echo -e "${green}システムには wget がインストールされています${plain}"
        else
            # wget をインストール
            echo -e "${green}wget がインストールされていません。インストールを開始します${plain}"
            apt-get install wget -y
            if [ $? -eq 0 ]; then
                echo -e "${green}wget のインストールが成功しました${plain}"
            else
                echo -e "${red}wget のインストールに失敗しました${plain}"
                exit 1
            fi
        fi
    else
        echo -e "${red}サポートされていないシステムの種類です${plain}"
        exit 1
    fi

    # Soga のインストールを開始
    echo -e "${green}/etc/soga フォルダが存在しないため、Sogaのインストールを開始します${plain}"
    bash <(curl -Ls https://raw.githubusercontent.com/vaxilu/soga/master/install.sh)
    if [ $? -eq 0 ]; then
        echo -e "${green}Soga のインストールが成功しました${plain}"
    else
        echo -e "${red}Soga のインストールに失敗しました${plain}"
        exit 1
    fi
fi

# スクリプトの実行が完了しました
while true; do
    # インストール完了後のメッセージ
    echo -e "${yellow_light}涩龙のSoga設定スクリプトをご利用いただきありがとうございます！${plain}"

    # /etc/soga フォルダの存在を再確認
    if [ -d /etc/soga ]; then
        # ユーザーに機能の選択を促す
        echo -e "${red}実行する機能を選択してください：${plain}"
        echo -e "${green}1. Sogaの設定${plain}"
        echo -e "${green}2. ブロック解除の設定${plain}"
        echo -e "${green}3. オーディットの設定${plain}"
        echo -e "${green}4. Sogaの再インストール${plain}"
        echo -e "${green}5. メディアストリームのテスト${plain}"
        echo -e "${green}0. スクリプトの終了${plain}"

        # ユーザーの入力を受け取る
        read -p "$(echo -e "${yellow}番号を入力してください: ${plain}")" function_number

        # ユーザーの入力に基づいて異なる機能を実行する
        case $function_number in
            1)
                echo -e "${green}Sogaの設定${plain}"

                # ユーザーに操作タイプの選択を促す
                read -p "$(echo -e "${yellow}操作タイプを選択してください：${plain} [1. ファイル設定 / 2. 設定の変更]: ")" config_option

                case $config_option in
                    1)
                        echo -e "${green}設定ファイルのダウンロード${plain}"

                        # /etc/soga に移動して https://github.com/WuYtUgXw/almasoga の soga.conf をダウンロードし、元の soga.conf を置き換える
                        wget -O /etc/soga/soga.conf https://github.com/WuYtUgXw/almasoga/raw/main/soga.conf
                        if [ $? -eq 0 ]; then
                            echo -e "${green}soga.conf の置換に成功しました${plain}"
                        else
                            echo -e "${red}soga.conf の置換に失敗しました${plain}"
                            exit 1
                        fi

                        # 「ノードID」を入力してもらい、/etc/soga/soga.conf の node_id= の後に入力した値を入れる
                        read -p "$(echo -e "${yellow}ノードIDを入力してください：${plain}")" node_id
                        sed -i "s/node_id=/node_id=$node_id/" /etc/soga/soga.conf

                        # 保存して Soga サービスを再起動
                        systemctl restart soga
                        if [ $? -eq 0 ]; then
                            echo -e "${green}Sogaの設定が更新され、サービスが再起動しました${plain}"
                        else
                            echo -e "${red}Sogaサービスの再起動に失敗しました${plain}"
                            exit 1
                        fi
                        ;;
                    2)
                        echo -e "${green}設定ファイルの変更${plain}"

                        # 「ノードID」を入力してもらい、/etc/soga/soga.conf の node_id= を入力した値に変更
                        read -p "$(echo -e "${yellow}新しいノードIDを入力してください：${plain}")" new_node_id
                        sed -i "s/node_id=.*/node_id=$new_node_id/" /etc/soga/soga.conf

                        # 保存して Soga サービスを再起動
                        systemctl restart soga
                        if [ $? -eq 0 ]; then
                            echo -e "${green}Sogaの設定が更新され、サービスが再起動しました${plain}"
                        else
                            echo -e "${red}Sogaサービスの再起動に失敗しました${plain}"
                            exit 1
                        fi
                        ;;
                    *)
                        echo -e "${red}無効なオプションです${plain}"
                        exit 1
                        ;;
                esac
                ;;
            2)
                echo -e "${green}ブロック解除の設定${plain}"
                
                # ユーザーにブロック解除のタイプの選択を促す
                read -p "$(echo -e "${yellow}ブロック解除のタイプを選択してください：${plain} [1. DNSブロック解除 / 2. DNS変更]: ")" unlock_option

                case $unlock_option in
                    1)
                        echo -e "${green}DNSブロック解除${plain}"

                        # https://github.com/WuYtUgXw/almasoga の dns.yml をダウンロードし、/etc/soga の元の dns.yml を置き換える
                        wget -O /etc/soga/dns.yml https://github.com/WuYtUgXw/almasoga/raw/main/dns.yml
                        if [ $? -eq 0 ]; then
                            echo -e "${green}dns.yml の置換に成功しました${plain}"
                        else
                            echo -e "${red}dns.yml の置換に失敗しました${plain}"
                            exit 1
                        fi

                        # 「地域の略称」を入力してもらい、/etc/soga の dns.yml にある sin.core を入力した値に変更
                        read -p "$(echo -e "${yellow}地域の略称を入力してください：${plain}")" region_abbr

                        case $region_abbr in
                            hk)
                                sed -i "s/sin.core/hkg.core/" /etc/soga/dns.yml
                                ;;
                            sg)
                                sed -i "s/sin.core/sin.core/" /etc/soga/dns.yml
                                ;;
                            jp)
                                sed -i "s/sin.core/nrt.core/" /etc/soga/dns.yml
                                ;;
                            us)
                                sed -i "s/sin.core/lax.core/" /etc/soga/dns.yml
                                ;;
                            *)
                                echo -e "${red}無効な地域略称です${plain}"
                                exit 1
                                ;;
                        esac

                        echo -e "${green}DNSブロック解除の設定が完了しました${plain}"
                        ;;
                    2)
                        echo -e "${green}DNS変更${plain}"

                        # 「地域の略称」を入力してもらい、/etc/soga の dns.yml にある sin.core を入力した値に変更
                        read -p "$(echo -e "${yellow}地域の略称を入力してください：${plain}")" region_abbr

                        case $region_abbr in
                            hk)
                                replace_rules="s/sin.core/hkg.core/;s/hkg.core/hkg.core/;s/nrt.core/hkg.core/;s/lax.core/hkg.core/;"
                                ;;
                            sg)
                                replace_rules="s/sin.core/sin.core/;s/hkg.core/sin.core/;s/nrt.core/sin.core/;s/lax.core/sin.core/;"
                                ;;
                            jp)
                                replace_rules="s/sin.core/nrt.core/;s/hkg.core/nrt.core/;s/nrt.core/nrt.core/;s/lax.core/nrt.core/;"
                                ;;
                            us)
                                replace_rules="s/sin.core/lax.core/;s/hkg.core/lax.core/;s/nrt.core/lax.core/;s/lax.core/lax.core/;"
                                ;;
                            *)
                                echo -e "${red}無効な地域略称です: $region_abbr${plain}"
                                exit 1
                                ;;
                        esac

                        # 置換ルールを適用
                        sed -i "${replace_rules}" /etc/soga/dns.yml

                        echo -e "${green}DNS変更の設定が完了しました${plain}"
                        ;;
                    *)
                        echo -e "${red}無効なオプションです${plain}"
                        exit 1
                        ;;
                esac
                ;;
3)
    echo -e "${green}監査設定${plain}"

    # ユーザーに操作タイプを選択するように促す
    read -p "$(echo -e "${yellow}操作タイプの選択：${plain} [1. 監査の削除 / 2. 監査の追加]: ")" audit_option

    case $audit_option in
        1)
            echo -e "${green}監査の削除${plain}"
            # /etc/soga/blockList ファイルの内容を削除
            echo -n > /etc/soga/blockList
            if [ $? -eq 0 ]; then
                echo -e "${green}削除成功${plain}"
            else
                echo -e "${red}削除失敗${plain}"
                exit 1
            fi
            ;;
        2)
            echo -e "${green}監査の追加${plain}"
            # https://github.com/WuYtUgXw/almasoga の blockList をダウンロードし、/etc/soga の既存の blockList を置き換える
            wget -O /etc/soga/blockList https://github.com/WuYtUgXw/almasoga/raw/main/blockList
            if [ $? -eq 0 ]; then
                echo -e "${green}blockList の置き換え成功${plain}"
            else
                echo -e "${red}blockList の置き換え失敗${plain}"
                exit 1
            fi
            ;;
        *)
            echo -e "${green}無効なオプション${plain}"
            exit 1
            ;;
    esac
    ;;
4)
    echo -e "${green}Soga再インストール${plain}"

    # 確認を求める
    read -p "$(echo -e "${yellow}Sogaを再インストールしますか？ (yes/no): ${plain}")" reinstall_choice

    if [ "$reinstall_choice" == "yes" ] || [ "$reinstall_choice" == "y" ]; then
        echo -e "${yellow_light}/etc/soga を削除しています...${plain}"
        rm -rf /etc/soga

        # インストールを進める
        echo -e "${green}/etc/soga フォルダが削除されました。Sogaの再インストールを開始します${plain}"
        bash <(curl -Ls https://raw.githubusercontent.com/vaxilu/soga/master/install.sh)
        if [ $? -eq 0 ]; then
            echo -e "${green}Sogaの再インストール成功${plain}"
        else
            echo -e "${red}Sogaのインストール失敗${plain}"
            exit 1
        fi
    else
        echo -e "${yellow_light}Soga再インストールはキャンセルされました${plain}"
        exit 0
    fi
    ;;
5)
    echo -e "${green}ストリーミングテスト${plain}"
    bash <(curl -L -s https://netflix.dad/detect-script)
    ;;
0)
    echo -e "${yellow_light}スクリプトの終了${plain}"
    exit 0
    ;;
*)
    echo -e "${green}無効な操作番号${plain}"
    exit 1
    ;;
esac
fi
done

