# 使用 docker 搭建 shadowsocks 服务

## 安装

1. 在 linux 服务器上安装 docker 环境

	```bash
	## 使用官方脚本安装 docker
	curl -fsSL get.docker.com -o - | sh

	## 安装 docker-compose
	curl -fsSL https://github.com/docker/compose/releases/latest | \
	    sed -nE "/<code>curl/N;/chmod/s/^.*<code>//p" | sh
	```

2. 在 linux 服务器上运行服务

	```bash
	git clone https://github.com/arzyu/shadowsocks
	cd shadowsocks

	## 修改 docker-compose.yml 中的密码（shadowsocks 客户端中使用）
	## 然后后台运行 docker-compose
	docker-compose up -d

	## 将此 docker-compose 添加到系统服务（systemd）以跟随 linux 服务器自启动
	./setup.sh
	```

3. 在本地运行一个 [shadowsocks 客户端](http://shadowsocks.org/en/download/clients.html)

	* macOS 推荐使用 [ShadowsocksX-NG](https://github.com/shadowsocks/ShadowsocksX-NG/releases/latest)；Windows 10+ 推荐使用 [shadowsocks-windows](https://github.com/shadowsocks/shadowsocks-windows/releases/latest)。

	* 在客户端中添加服务器设置，加密方法使用 `aes-256-cfb`。![客户端配置范例](https://user-images.githubusercontent.com/1270145/46902739-e68ed180-cefc-11e8-989b-a2fef96da92b.png)

4. 大功告成

## macOS

如果经常需要改变 shadowsocks 的 server_port（默认为 8388），那么可以在 macOS 上运行下面这条命令，它可以帮你自动修改 docker-compose 和 ShadowsocksX-NG 中的 server_port 并重启服务和客户端。

**注意：命令中有 3 处需要根据自己的情况做修改**

* `port=8383`，把 8383 换成你想用的新端口号
* `USER@DOMAIN`，替换成你的 linux 服务器登录信息
* `/PATH/TO/SHADOWSOCKS`，对应 `docker-compose.yml` 文件所在目录

```bash
port=8383 && { ssh USER@DOMAIN bash << EOT
## change docker-compose server_port
cd /PATH/TO/SHADOWSOCKS
docker-compose down
sed -i -E "N;s/(ports:[^0-9]*)[0-9]+:/\1$port:/" docker-compose.yml
docker-compose up -d
EOT
} && bash << EOT
## change client server_port
pkill ShadowsocksX-NG
/usr/libexec/PlistBuddy -c "Set :ServerProfiles:0:ServerPort $port" \
    ~/Library/Preferences/com.qiuyuzhou.ShadowsocksX-NG.plist
killall -u $(whoami) cfprefsd # clear preferences cache
open /Applications/ShadowsocksX-NG.app
EOT
```

**提示：这条命令很长，首次使用后，下次可以借助终端的 bck-i-search 功能（`ctrl + r`）搜索到它，修改端口再次运行**

## License

wtfpl
