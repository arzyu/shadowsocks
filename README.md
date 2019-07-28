# Linux 一键部署 Shadowsocks 服务

在 Linux 服务器上运行命令一键部署 Shadowsocks 服务。

## 部署

### 安装：

```shell
curl -fsSL https://github.com/arzyu/shadowsocks/raw/master/setup.sh | bash
```

这个脚本帮你：

 * 使用官方脚本安装 docker（如果没有检测到 docker）
 * 使用 `shadowsocks/shadowsocks-libev` 镜像启动一个 Shadowsocks 服务
 * 配置 systemd，使 Shadowsocks 服务跟随系统自启动

注意：运行时会提示设置**端口**和**密码**。

### 卸载：

```shell
curl -fsSL https://github.com/arzyu/shadowsocks/raw/master/setup.sh | bash -s -- --remove
```

## 客户端及配置

 * macOS: [ShadowsocksX-NG](https://github.com/shadowsocks/ShadowsocksX-NG/releases/latest)
 * Windows 10: [shadowsocks-windows](https://github.com/shadowsocks/shadowsocks-windows/releases/latest)

![客户端配置范例](https://user-images.githubusercontent.com/1270145/62014025-30b41b80-b1ce-11e9-9ba5-47a19007f5c2.png)

注意：加密方法使用 `aes-256-gcm`。

## License

wtfpl
