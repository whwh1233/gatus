# 部署指南

## 环境要求

- Go 1.22+（本地构建）或 Docker
- SQLite（默认存储）

## 环境变量

| 变量 | 说明 |
|------|------|
| `CLAUDE_CODEMAX_KEY` | Claude Code Max API Key |
| `GPT54_KEY` | GPT 5.4 API Key |

创建 `.env` 文件：

```bash
cp .env.example .env
# 编辑 .env 填入实际的 API Key
```

`.env.example` 内容：

```
CLAUDE_CODEMAX_KEY=sk-xxx
GPT54_KEY=sk-xxx
```

## 方式一：直接运行

```bash
# 安装依赖并构建
make install

# 运行
source .env
ENVIRONMENT=dev GATUS_CONFIG_PATH=./config.yaml ./gatus
```

## 方式二：Docker

```bash
# 构建镜像
docker build -t gatus .

# 运行
docker run -d \
  --name gatus \
  -p 8080:8080 \
  -e CLAUDE_CODEMAX_KEY=sk-xxx \
  -e GPT54_KEY=sk-xxx \
  gatus
```

## 方式三：Systemd（Linux 服务器）

1. 构建二进制：

```bash
make install
sudo cp gatus /usr/local/bin/
```

2. 创建配置目录：

```bash
sudo mkdir -p /etc/gatus
sudo cp config.yaml /etc/gatus/
```

3. 创建环境变量文件：

```bash
sudo tee /etc/gatus/gatus.env > /dev/null <<EOF
CLAUDE_CODEMAX_KEY=sk-xxx
GPT54_KEY=sk-xxx
EOF
sudo chmod 600 /etc/gatus/gatus.env
```

4. 创建 systemd 服务：

```bash
sudo tee /etc/systemd/system/gatus.service > /dev/null <<EOF
[Unit]
Description=Gatus - AI Channel Status Monitor
After=network.target

[Service]
Type=simple
EnvironmentFile=/etc/gatus/gatus.env
Environment=GATUS_CONFIG_PATH=/etc/gatus/config.yaml
ExecStart=/usr/local/bin/gatus
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
```

5. 启动服务：

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now gatus
```

6. 查看状态：

```bash
sudo systemctl status gatus
sudo journalctl -u gatus -f
```

## 访问

启动后访问 http://localhost:8080 查看状态面板。
