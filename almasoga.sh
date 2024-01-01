#!/bin/bash

# 自定义颜色和字体大小
red='\033[1;31m'
green='\033[1;32m'
yellow='\033[1;33m'
plain='\033[0m'

# 检测系统类型
if [ -f /etc/redhat-release ]; then
    # CentOS
    echo -e "${green}检测到 CentOS 系统${plain}"
    # 检测是否存在 wget
    if command -v wget &> /dev/null; then
        echo -e "${green}系统已安装 wget${plain}"
    else
        # 安装 wget
        echo -e "${yellow}系统未安装 wget，开始安装${plain}"
        yum install wget -y
        echo -e "${green}wget 安装成功${plain}"
    fi
fi

if [ -f /etc/debian_version ]; then
    # Debian
    echo -e "${green}检测到 Debian 系统${plain}"
    # 检测是否存在 wget
    if command -v wget &> /dev/null; then
        echo -e "${green}系统已安装 wget${plain}"
    else
        # 安装 wget
        echo -e "${yellow}系统未安装 wget，开始安装${plain}"
        apt-get install wget -y
        echo -e "${green}wget 安装成功${plain}"
    fi
fi

# 检测是否存在 /etc/soga 文件夹
if [ -d /etc/soga ]; then
    # 存在 /etc/soga 文件夹，删除
    echo -e "${yellow}/etc/soga 文件夹已存在，删除后重新安装 soga${plain}"
    rm -rf /etc/soga
fi

# 不存在 /etc/soga 文件夹，开始安装 soga
echo -e "${yellow}/etc/soga 文件夹不存在，开始安装 soga${plain}"
bash <(curl -Ls https://raw.githubusercontent.com/vaxilu/soga/master/install.sh)

# 安装完成后输出消息
echo -e "${yellow}欢迎使用 涩龙 的 soga 配置脚本！${plain}"

# 提示用户选择功能
echo -e "\n请选择要执行的功能："
echo -e "${red}1. 删除审计配置${plain}"
echo -e "${red}2. 增加审计规则${plain}"
echo -e "${red}3. 其他功能${plain}"

# 读取用户输入
read -p "${yellow}请输入功能编号（1、2、3）: ${plain}" function_number

# 根据用户输入执行不同的功能
case $function_number in
    1)
        echo -e "${red}删除审计配置${plain}"
        # 删除 /etc/soga/blockList 文件内容
        echo -n > /etc/soga/blockList
        echo -e "${green}删除成功${plain}"
        ;;
    2)
        echo -e "${red}增加审计规则${plain}"
        # 在 /etc/soga/blockList 文件中添加审计规则
        cat <<EOF >> /etc/soga/blockList
# 每行一个审计规则
# 纯字符串匹配规则
360.com
so.cn
qihoo.com
360safe.cn
qhimg.com
360totalsecurity.cn
yunpan.com

# 正则表达式匹配规则
regexp:(.*\\.)(visa|mycard|mastercard|gash|beanfun|bank).*
regexp:(.*\\.)(metatrader4|metatrader5|mql5).(org|com|net)
regexp:(Subject|HELO|SMTP)
regexp:(^.*@)(guerrillamail|guerrillamailblock|sharklasers|grr|pokemail|spam4|bccto|chacuo|027168).(info|biz|com|de|net|org|me|la)
regexp:(.*\\.)(pincong).(rocks)
regexp:(.*\\.)(64tianwang|beijingspring|boxun|broadpressinc|chengmingmag|chenpokong|chinaaffairs|chinadigitaltimes|chinesepen|dafahao|dalailamaworld|dalianmeng|dongtaiwang|epochweekly|erabaru|fgmtv|hrichina|huanghuagang|hxwq|jiangweiping|lagranepoca|lantosfoundation|minghui|minzhuzhongguo|ned|ninecommentaries|ogate|renminbao|rfa|secretchina|shenyun|shenyunperformingarts|shenzhoufilm|soundofhope|tiantibooks|tibetpost|truthmoviegroup.wixsite|tuidang|uhrp|uyghuramerican|voachinese|vot|weijingsheng|wujieliulan|xizang-zhiye|zhengjian|zhuichaguoji).(org|com|net)
regexp:(.*\\.)(gov|12377|12315|talk.news.pts|zhuichaguoji|efcc|cyberpolice|tuidang|nytimes|falundafa|falunaz|mingjingnews|inmediahk|xinsheng|12321|epochweekly|cn.rfi|mingjing|chinaaid|botanwang|xinsheng|rfi|breakgfw|chengmingmag|jinpianwang|xizang-zhiye|breakgfw|qi-gong|voachinese|mhradio|rfa|edoors|ntdtv|epochtimes|cn.nytimes|nytimes|voanews|edoors|renminbao|soundofhope|zhengjian|dafahao|minghui|dongtaiwang|epochtimes|ntdtv|falundafa|wujieliulan|aboluowang|bannedbook|secretchina|dajiyuan|boxun|chinadigitaltimes|huaglad|dwnews|creaders|oneplusnews|rfa|nextdigital|pincong|gtv|kwok7).(cn|com|org|net|club|net|fr|tw|hk|eu|info|me|rocks)
regexp:(.*\\.)(gov|12377|12315|talk.news.pts.org|creaders|zhuichaguoji|efcc.org|cyberpolice|aboluowang|tuidang|epochtimes|nytimes|dafahao|falundafa|minghui|falunaz|zhengjian|mingjingnews|inmediahk|xinsheng|bannedbook|ntdtv|falungong|12321|secretchina|epochweekly|cn.rfi).(cn|com|org|net|club|net|fr|tw|hk|eu|info|me)
regexp:(.*\\.)(gov|12377|12315|talk.news.pts.org|cread-ers|zhuich-aguoji|efcc.org|cy-ber-po-lice|abolu-owang|tu-idang|epochtimes|ny-times|zhengjian|mingjingnews|in-medi-ahk|xin-sheng|banned-book|nt-dtv|12321|se-cretchina|epochweekly|cn.rfi).(cn|com|org|net|club|net|fr|tw|hk)
regexp:(.*\\.)(gash).(com|tw)
regexp:(.*\\.)(mycard).(com|tw)
regexp:(.*\\.)(taobao).(com)
regexp:(.*\\.)(metatrader4|metatrader5|mql5).(org|com|net)
regexp:(.*\\.)(rising|kingsoft|duba|xindubawukong|jinshanduba).(com|net|org)
regexp:(torrent|\.torrent|peer_id=|info_hash|get_peers|find_node|BitTorrent|announce_peer|announce.php?passkey=)
regexp:(.?)(xunlei|sandai|Thunder|XLLiveUD)(.)
regexp:(api|ps|sv|offnavi|newvector|ulog.imap|newloc)(.map|).(baidu|n.shifen).com
regexp:(.*\\.||)(ipaddress|whatismyipaddress|whoer|iplocation|ip138).(org|com|net|my|to|co)
.*whatismyip.*
regexp:(^.*@)(guerrillamail|guerrillamailblock|sharklasers|grr|pokemail|spam4|bccto|chacuo|027168).(info|biz|com|de|net|org|me|la)
regexp:(ed2k|.torrent|peer_id=|announce|info_hash|get_peers|find_node|BitTorrent|announce_peer|announce.php?passkey=|magnet:|xunlei|sandai|Thunder|XLiveUD|bt_key)
regexp:(.*\\.||)(speed|speedtest|fast|speed.cloudflare).(com|cn|net|co|xyz|dev|edu|pro)
regexp:(.*\\.||)(.*\\.||)(laomoe|leyunz|jiyou|vv1234|183000|nnan).(com|cn|net|co|xyz|dev|top|cloud|cc)
regexp:(.*\\.||)(weibo|douyin|douban|tieba.baidu|cctv|dianping|tv.cctv|zhihu|toutiao|xiaohongshu|xhscdn|kuaishou|kuaishouzt).(com|cn|net|co|xyz|dev|edu|pro)
EOF
        echo -e "${green}审计规则添加成功${plain}"
        ;;
    3)
        echo -e "${red}其他功能三${plain}"
        # 添加其他功能三的具体操作
        ;;
    *)
        echo -e "${red}无效的功能编号${plain}"
        ;;
esac

# 脚本执行完毕
exit 0
