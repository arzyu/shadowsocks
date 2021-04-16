# Linux 一键安装 Shadowsocks 服务

已测试 Linux 版本：CentOS 7 / Debian 10 / Fedora 30 / Ubuntu 18.04/20.04

## 服务端部署

### 安装：

```shell
curl -fsSL https://github.com/arzyu/shadowsocks/raw/master/setup.sh | bash
```

这个脚本帮你：

 * 安装 docker：如果没有检测到 docker，就运行 [docker 官方安装脚本](https://github.com/docker/docker-install)
 * 启动 Shadowsocks 服务：使用 docker 运行 [shadowsocks/shadowsocks-libev](https://github.com/shadowsocks/shadowsocks-libev#docker) 镜像

注意：运行时会提示设置**端口**和**密码**；安装完成后，如需修改端口或密码，请再次运行此安装命令。

上述安装脚本会为我们创建一个名为 `shadowsocks` 服务容器，因此可以使用 docker 命令来控制 Shadowsocks 服务的启动/重启/停止：

```shell
# 启动/重启/停止 shadowsocks 服务容器
docker start shadowsocks
docker restart shadowsocks
docker stop shadowsocks
```

### 更新：

```shell
curl -fsSL https://github.com/arzyu/shadowsocks/raw/master/setup.sh | bash -s -- update
```

这个脚本帮你更新 shadowsocks 服务到最新版本。

### 卸载：

```shell
curl -fsSL https://github.com/arzyu/shadowsocks/raw/master/setup.sh | bash -s -- remove
```

移除 Shadowsocks 服务，但**不会**卸载 docker。

## 客户端及配置

常用的 [Shadowsocks 客户端](http://shadowsocks.org/en/download/clients.html)：

 * macOS: [ShadowsocksX-NG](https://github.com/shadowsocks/ShadowsocksX-NG/releases/latest)
 * Windows: [shadowsocks-windows](https://github.com/shadowsocks/shadowsocks-windows/releases/latest)
 * Android: [shadowsocks-android](https://github.com/shadowsocks/shadowsocks-android/releases/latest)
 * iOS: [Outline-app](https://itunes.apple.com/app/outline-app/id1356177741)

![客户端配置范例](https://user-images.githubusercontent.com/1270145/62014025-30b41b80-b1ce-11e9-9ba5-47a19007f5c2.png)

注意：加密方法使用 `aes-256-gcm`。

## License

wtfpl
