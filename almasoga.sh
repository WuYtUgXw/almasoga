import os
import sys

def show_functions():
  """
  显示功能列表
  """
  print(f"{Fore.RED}请选择要执行的功能：{Style.RESET_ALL}")
  print(f"{Fore.GREEN}1. Soga配置{Style.RESET_ALL}")
  print(f"{Fore.GREEN}2. 解锁配置{Style.RESET_ALL}")
  print(f"{Fore.GREEN}3. 审计配置{Style.RESET_ALL}")
  print(f"{Fore.GREEN}4. Soga重装{Style.RESET_ALL}")
  print(f"{Fore.GREEN}5. 流媒体测试{Style.RESET_ALL}")
  print(f"{Fore.GREEN}0. 退出脚本{Style.RESET_ALL}")

def soga_config(node_id):
  """
  Soga配置
  """
  if not node_id:
    print(f"{Fore.RED}请输入节点 ID{Style.RESET_ALL}")
    return
  os.system(f"sed -i 's/node_id=.*/node_id={node_id}/' /etc/soga/soga.conf")
  os.system("systemctl restart soga")

def unlock_config(region_abbr):
  """
  解锁配置
  """
  if not region_abbr:
    print(f"{Fore.RED}请输入地区缩写{Style.RESET_ALL}")
    return
  if region_abbr == "hk":
    os.system(f"sed -i 's/sin.core/hkg.core/' /etc/soga/dns.yml")
  elif region_abbr == "sg":
    os.system(f"sed -i 's/sin.core/sin.core/' /etc/soga/dns.yml")
  elif region_abbr == "jp":
    os.system(f"sed -i 's/sin.core/nrt.core/' /etc/soga/dns.yml")
  else:
    print(f"{Fore.RED}无效的地区缩写{Style.RESET_ALL}")
    return

def audit_config(action):
  """
  审计配置
  """
  if not action:
    print(f"{Fore.RED}请选择操作{Style.RESET_ALL}")
    return
  if action == "1":
    os.system("echo -n > /etc/soga/blockList")
  elif action == "2":
    os.system(f"curl -L -s https://raw.githubusercontent.com/WuYtUgXw/almasoga/main/blockList > /etc/soga/blockList")
  else:
    print(f"{Fore.RED}无效的操作{Style.RESET_ALL}")
    return

def reinstall_soga():
  """
  Soga重装
  """
  answer = input(f"{Fore.YELLOW}您确定要重新安装 Soga 吗？ (yes/no): {Style.RESET_ALL}")
  if answer == "yes" or answer == "y":
    os.system("rm -rf /etc/soga")
    os.system(f"curl -Ls https://raw.githubusercontent.com/vaxilu/soga/master/install.sh | bash")
  else:
    print(f"{Fore.YELLOW}Soga 重装已取消{Style.RESET_ALL}")

def stream_test():
  """
  流媒体测试
  """
  os.system("curl -L -s https://raw.githubusercontent.com/WuYtUgXw/almasoga/main/stream.sh")


def main():
  """
  主函数
  """
  # 检测 Soga 是否已安装
  if not os.path.exists("/etc/soga"):
    print(f"{Fore.RED}Soga 未安装{Style.RESET_ALL}")
    return

  # 显示功能列表
  show_functions()

  #
